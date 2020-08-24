---
nav_exclude: true
---
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

**Step 1: Install `detect-secrets` and `pre-commit` from an admin prompt:**

```cmd
pip install detect-secrets pre-commit
```

**Step 2: Setup your local repo with the required `pre-commit` hooks:**

```cmd
cd .../dataops-infra
```

```cmd
pre-commit install
```

**Step 3: Check for a file called `.pre-commit-config.yaml` at the root of the repo:**

If the file doesn't yet exist, create the file with the following contents:

```yml
repos:
  - repo: https://github.com/yelp/detect-secrets
    rev: v0.14.2
    hooks:
      - id: detect-secrets
        args: ["--baseline", ".secrets.baseline"]
        exclude: .*/tests/.*
```

_That's it! You're done (at least for this repo). Repeat steps 2 and 3 for any additional git repositories which you want to protect._

### Dealing with false-positives

_If you run into false positives, try one of the following 2 options._

Option A:

Add an inline comment to the end of the offending
line(s): `# pragma: allowlist secret`

Option B:

Rebaseline and audit the results before committing.

## Periodically scan and audit any findings

Update and audit your baseline:

```cmd
detect-secrets scan --update .secrets.baseline
detect-secrets audit .secrets.baseline
```
