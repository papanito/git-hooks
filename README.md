## Shared git-hooks

These are my personal git-hooks as an enhancements of the default [pre-commit](https://pre-commit.com/)

## What is pre-commit?

**pre-commit** is a framework for managing and maintaining Git hooks. It allows you to automatically run checks (formatters, linters, tests, security scans, etc.) before commits are created.

Typical benefits:

- Enforces consistent code style
- Prevents committing broken or insecure code
- Works the same for every contributor
- Easy to version and share hooks

## Get started

If you already installed pre-commit just enabled it in the repo as follows

```shell
curl -q "hhttps://gitlab.com/papanito/git-hooks/-/raw/main/config/.pre-commit-config.yaml" \
  -o .pre-commit-config.yaml  && \
  pre-commit install && \
  pre-commit autoupdate
```

If you want to use the `commitlint` hook, install the [`commit-msg`](https://pre-commit.com/#commit-msg) hook in your project repo:

```shell
pre-commit install --hook-type commit-msg
```

Otherwise follow the instructions below

### Pre-requisites

You can install `pre-commit` with the default package manager. However, probably a more recent version is available via `pip`

1. Ensure you have `pipx` installed - in case you are using `prek`, which tries to install it but it does not work in our environment

   ```shell
   sudo apt install pipx
   ```

2. Add pre-commit as a development dependency:

    ```bash
    pip --user install pre-commit
    ```

    or

    ```bash
    pipx install pre-commit
    ```

### Use it (in the repo)

1. Create `.pre-commit-config.yaml`

    At the root of your repository, create a `.pre-commit-config.yaml` file:

    ```yaml
    repos:
    - repo: https://gitlab.com/papanito/git-hooks.git
      rev: v1.0.0
      hooks:
        - id: get_shared_config
    - repo: https://github.com/pre-commit/pre-commit-hooks
      rev: v5.0.0
      hooks:
        - id: check-yaml
        - id: trailing-whitespace
    - repo: https://github.com/antonbabenko/pre-commit-terraform
      rev: v1.99.3
      hooks:
        - id: terraform_fmt
        - id: terraform_docs
        - id: terraform_tflint
        - id: terraform_trivy
    ```

   Find some examples under [config](./config/README.md)

2. Instal the Git Hooks

   ```shell
   pre-commit install
   ```

   This installs the Git pre-commit hook locally. From now on, configured checks will run automatically before each commit.

3. Run Hooks Manually (Optional)

   To run all hooks against all files:

   ```shell
   pre-commit run --all-files
   ```

## Hooks

### get_shared_config

This repo contains default config files for different lanuguages unde [config](./config/). The hook downloads the config files into the project repo. This allows for updating changes in a central place and the developer will always get latest config files, ones (s)he starts committing.

The hook should detect automatically which project type and downloads the respective files.

### commitlint

- Requires a `commitlint` config file in the repo's root according to [committing](https://commitlint.js.org/reference/configuration.html#configuration).
- Enable it by adding the following to your `.pre-commit-config.yaml`:

  ```yaml
  - repo: https://gitlab.com/papanito/git-hooks.git
    rev: <latest tag>
    hooks:
        - id: commitlint
          stages: [commit-msg]
  ```

- You can add your [shared configurations](https://commitlint.js.org/reference/configuration.html#shareable-configuration) as a
dependency using the `additional_dependencies` parameter of the hooks
  
  ```yaml
  - repo: https://gitlab.com/papanito/git-hooks.git
    rev: <latest tag>
    hooks:
        - id: commitlint
          stages: [commit-msg]
          additional_dependencies: ['@commitlint/config-angular']
  ```
