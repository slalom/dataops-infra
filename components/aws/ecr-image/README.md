---
parent: Infrastructure Components
title: AWS ECR-Image
nav_exclude: false
---
# AWS ECR-Image

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/ecr-image?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/ecr-image)

## Overview


Error: unknown flag: --sort## Prereqs:

_To use this module, you will need the following components:_

### 1. ECR Credential Manager

Once installed, the credential manager will pickup AWS credentials and use those specified in the `AWS_SHARED_CREDENTIALS_FILE` environment variable - which can be quickly set using the `environment` module's terraform output in the "AWS User Switch Cmd".

**To install on Windows:**

```cmd
# Install Go
choco install golang

# Install ECR Credential Helper
go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login
```

**To install on Mac/Linux:**

* [https://github.com/awslabs/amazon-ecr-credential-helper#user-content-installing](https://github.com/awslabs/amazon-ecr-credential-helper#user-content-installing)

**Configure Docker to use the ECR Credential Helper:**

Replace the contents of `~/.docker/config.json` (or `%USERPROFILE%/.docker/config.json` on Windows) with:

```json
{ "credsStore": "ecr-login" }
```

**Set your shared credentials file:**

On Windows:

```cmd
SET AWS_SHARED_CREDENTIALS_FILE=[repo-root-dir]/.secrets/aws-credentials
```

On Linux/Mac:

```cmd
export AWS_SHARED_CREDENTIALS_FILE=[repo-root-dir]/.secrets/aws-credentials
```

### 2. AWS Powershell Tools Module (Windows only)

Install with:

```ps
Install-Module -name AWSPowerShell.NetCore
```

In order to then use this module for manual executions, you will need to load it into your powershell session:

```ps
Import-Module AWSPowerShell.NetCore
```

For more info: [https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html#ps-installing-awspowershellnetcore](https://docs.aws.amazon.com/powershell/latest/userguide/pstools-getting-set-up-windows.html#ps-installing-awspowershellnetcore)


---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecr-image/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecr-image/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecr-image/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
