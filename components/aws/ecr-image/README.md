
# AWS ECR-Image

`/components/aws/ecr-image`

## Overview


ECR (Elastic Compute Repository) is the private-hosted AWS
equivalent of DockerHub. ECR allows you to securely publish
docker images which should not be accessible to external users.

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_credentials\_file | Path to the AWS credentials file, used to ensure that the correct credentials are used during upload of the ECR image. | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| repository\_name | Name of Docker repository. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| source\_image\_path | Path to Docker image source. | `string` | n/a | yes |
| build\_args | Optional. Build arguments to use during `docker build`. | `map(string)` | `{}` | no |
| is\_disabled | Switch for disabling ECR image and push. | `bool` | `false` | no |
| tag | Tag to use for deployed Docker image. | `string` | `"latest"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecr\_image\_url | The full path to the ECR image, including image name. |
| ecr\_image\_url\_and\_tag | The full path to the ECR image, including image name and tag. |
| ecr\_repo\_arn | The unique ID (ARN) of the ECR repo. |
| ecr\_repo\_root | The path to the ECR repo, excluding image name. |
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

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/ecr-image/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/ecr-image/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/ecr-image/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
