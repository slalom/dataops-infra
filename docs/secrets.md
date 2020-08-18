# Securely Managing Secrets

## Preventing Security Leaks

## Proper storage of secrets

This repo has a `.gitignore` rule to automatically exclude files that are contained in any
folder titled `.secrets`. With the exception of `*.template` and `README.md` files, all
other files in these folders will be automatically excluded from git.

* DO NOT put secrets directly into your code files.
* DO always put secrets into dedicated secrets files which are hidden from git.
* DO migrate project secrets to a proper secrets manager (like AWS Secrets Manager) as
  soon as you are able.
* DO always double-check the first time you create a secrets file that it is not planned
  for addition into Git. (For instance, VS Code displays git-ignored files with a
  greyed-out font.)

## Install 'pre-commit' git hooks for automatic security leak prevention

From an admin prompt:

```cmd
pip install detect-secrets pre-commit
```

From your local repo root:

```cmd
pre-commit install
```

## Periodically scan and audit any findings

Create and audit your baseline:

```cmd
detect-secrets scan --update .secrets.baseline
detect-secrets audit .secrets.baseline
```
