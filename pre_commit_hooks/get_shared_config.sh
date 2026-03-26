#!/usr/bin/env bash
set -euo pipefail

SOURCE_PATHS=()
CONFIG_SUB_DIR=""
TYPE=""
# Detect project type
if git ls-files '*.tf' | grep -q .; then
  TYPE=tf
  ORIGIN_URL="$(git remote get-url origin 2>/dev/null || true)"
  if [[ -n "$ORIGIN_URL" ]] && [[ "${ORIGIN_URL,,}" == *tfm* ]]; then
    echo "Detected 'tfm' in origin URL: $ORIGIN_URL"
    CONFIG_SUB_DIR="tfm"
  fi
  SOURCE_PATHS=(
    "config/$TYPE/.tflint.hcl"
    "config/$TYPE/.gitignore"
    "config/$TYPE/$CONFIG_SUB_DIR/.terraform-docs.yml"
  )
elif git ls-files '*package.json' | grep -q .; then
  TYPE=nodejs
elif git ls-files 'pom.xml' | grep -q .; then
  TYPE=java
else
  exit 0
fi

# ========= USER CONFIG =========
# Internal source repo (SSH or HTTPS)
SOURCE_REPO="https://gitlab.com/papanito/git-hooks.git"
SOURCE_REF="main"
# Sparse checkout: fetch these directories (cone mode)
CHECKOUT_DIRS=("config") # pulls the entire config tree with subdirs

# Destination directory relative to this repo root ("" = project root)
DEST_DIR="" # e.g., "config"
# If true, block the commit when files were updated (forces re-run)
BLOCK_ON_UPDATE=true
# ========= END USER CONFIG =====

# ---- Internals
REPO_ROOT="$(git rev-parse --show-toplevel)"
CACHE_DIR="$HOME/.shared-configs"
SPARSE_DIR="$CACHE_DIR/worktree"
MARK_FILE="$CACHE_DIR/last_fetched_ref.txt"

mkdir -p "$CACHE_DIR"

# Global sentinel ensures we init only once
__CACHE_READY="${__CACHE_READY:-0}"

ensure_sparse_checkout_once() {
  # If we've already set up the cache in this process, exit early
  if [[ "$__CACHE_READY" -eq 1 ]]; then
    return 0
  fi

  echo "pre-commit: Checking latest $SOURCE_REF from $SOURCE_REPO..."

  # Clean git env that may be set in hook context
  unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE
  export GIT_TERMINAL_PROMPT=0

  # Best-effort probe
  LATEST_SHA="$(env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE \
    git ls-remote --heads --tags "$SOURCE_REPO" "$SOURCE_REF" | awk 'NR==1{print $1}')"

  NEED_FETCH=1
  if [[ -n "${LATEST_SHA:-}" && -f "$MARK_FILE" ]]; then
    if grep -q "$LATEST_SHA" "$MARK_FILE"; then
      NEED_FETCH=0
    fi
  fi

  if [[ "$NEED_FETCH" -eq 1 || ! -d "$SPARSE_DIR/.git" ]]; then
    echo "pre-commit: (Re)initializing sparse checkout..."
    rm -rf "$SPARSE_DIR"
    env -u GIT_DIR -u GIT_WORK_TREE -u GIT_INDEX_FILE \
      git clone --quiet --filter=blob:none --no-checkout --depth 1 \
      --branch "$SOURCE_REF" "$SOURCE_REPO" "$SPARSE_DIR" >/dev/null 2>&1
    pushd "$SPARSE_DIR" >/dev/null 2>&1
    git sparse-checkout init --cone >/dev/null 2>&1
    git sparse-checkout set "${CHECKOUT_DIRS[@]}" >/dev/null 2>&1
    # If you have many paths, set them in one call
    git checkout >/dev/null 2>&1
    popd >/dev/null
    [[ -n "${LATEST_SHA:-}" ]] && echo "$LATEST_SHA" >"$MARK_FILE"
  else
    echo "pre-commit: Using cached sparse checkout."
  fi

  # Mark as ready to prevent any further runs in this process
  __CACHE_READY=1
}

# ---- main ----
ensure_sparse_checkout_once

CHANGES=0

# Simple per-file copy. If you pass directories in SOURCE_PATHS,
# either expand them here or use a directory-aware branch as in my earlier message.
for src in "${SOURCE_PATHS[@]}"; do
  SRC_ABS="$SPARSE_DIR/$src"

  if [[ -d "$SRC_ABS" ]]; then
    # Optional directory handling: preserve structure under $src
    while IFS= read -r -d '' file; do
      rel="${file#"$SPARSE_DIR/$src/"}"
      dest_dir_abs="$REPO_ROOT/${DEST_DIR}"
      mkdir -p "$dest_dir_abs/$(dirname "$rel")"
      dest="$dest_dir_abs/$rel"
      if [[ ! -f "$dest" ]] || ! cmp -s "$file" "$dest"; then
        echo "pre-commit: Updating ${dest#$REPO_ROOT/}"
        cp -f "$file" "$dest"
        git -C "$REPO_ROOT" add "$dest"
        CHANGES=1
      else
        echo "pre-commit: No change for ${dest#$REPO_ROOT/}"
      fi
    done < <(find "$SRC_ABS" -type f -print0)
    continue
  fi

  # File path case
  if [[ ! -f "$SRC_ABS" ]]; then
    echo "pre-commit: ERROR: $src not found at $SRC_ABS" >&2
    exit 1
  fi

  base_name="$(basename "$src")"
  dest_dir_abs="$REPO_ROOT/${DEST_DIR}"
  mkdir -p "$dest_dir_abs"
  dest="$dest_dir_abs/$base_name"

  if [[ ! -f "$dest" ]] || ! cmp -s "$SRC_ABS" "$dest"; then
    echo "pre-commit: Updating ${dest#$REPO_ROOT/}"
    cp -f "$SRC_ABS" "$dest"
    git -C "$REPO_ROOT" add "$dest"
    CHANGES=1
  else
    echo "pre-commit: No change for ${dest#$REPO_ROOT/}"
  fi
done

if [[ "$CHANGES" -eq 1 && "${BLOCK_ON_UPDATE}" == "true" ]]; then
  echo "pre-commit: Updated config file(s) were staged. Re-run 'git commit' to include them."
  exit 1
fi
