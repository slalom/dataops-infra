# One-time Setup for Infrastructure Catalog Users

## Setup Guide

### 1. Install Local Software

Follow the steps in [Windows Development Quickstart](https://docs.dataops.tk/docs/windows_development.html), which will automatically install all of the following required tools: Terraform, Docker, VS Code, Python 3, and Git.

### 2. Install the Slalom DataOps library

```python
pip install slalom.dataops
```

### 3. Initialize a project

Run interactively:

```bash
s-infra --init my-project --interactive
cd my-project
```

Or run non-interactive:

```bash
s-infra --config my-project --config=/path/to/config.yml
cd my-project
```

### 4. Select Components and Configure

To configure, simply edit the generated yaml file, uncommenting desired features or settings and entering desired values as described in the file's code comments.

```bash
code my-project/config.yml
```

### 5. Initialize Terraform

```bash
cd my-project
cd infra
terraform init
```

### 6. Deploy your Infrastructure

```bash
cd my-project
cd infra
terraform apply
```
