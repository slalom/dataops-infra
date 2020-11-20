---
parent: Infrastructure Components
title: AWS ECR-Image
nav_exclude: false
---
# AWS ECR-Image

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/ecr-image?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/ecr-image)

## Overview


ECR (Elastic Compute Repository) is the private-hosted AWS
equivalent of DockerHub. ECR allows you to securely publish
docker images which should not be accessible to external users.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- aws

- null

## Required Inputs

The following input variables are required:

### name\_prefix

Description: Standard `name_prefix` module input. (Prefix counts towards 64-character max length for certain resource types.)

Type: `string`

### environment

Description: Standard `environment` module input.

Type:

```hcl
object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
```

### resource\_tags

Description: Standard `resource_tags` module input.

Type: `map(string)`

### repository\_name

Description: Name of Docker repository.

Type: `string`

### source\_image\_path

Description: Path to Docker image source.

Type: `string`

### aws\_credentials\_file

Description: Path to the AWS credentials file, used to ensure that the correct credentials are used during upload of the ECR image.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### build\_args

Description: Optional. Build arguments to use during `docker build`.

Type: `map(string)`

Default: `{}`

### tag

Description: Tag to use for deployed Docker image.

Type: `string`

Default: `"latest"`

## Outputs

The following outputs are exported:

### ecr\_repo\_arn

Description: The unique ID (ARN) of the ECR repo.

### ecr\_repo\_root

Description: The path to the ECR repo, excluding image name.

### ecr\_image\_url

Description: The full path to the ECR image, including image name.

### ecr\_image\_url\_and\_tag

Description: The full path to the ECR image, including image name and tag.
## Prereqs:

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
