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
PRELANG=tf && \
curl -q "hhttps://gitlab.com/papanito/git-hooks/-/raw/main/config/$PRELANG/.pre-commit-config.yaml" \
  -o .pre-commit-config.yaml  && \
  pre-commit install && \
  pre-commit autoupdate
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


