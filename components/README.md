---
parent: Infrastructure Components
title: .. Components
nav_exclude: false
---
# .. Components

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components)

## Overview


## Requirements

No requirements.

## Providers

No provider.

## Required Inputs

No required input.

## Optional Inputs

No optional input.

## Outputs

No output.
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


## Usage Example

**Sample inputs:**

```hcl
  secrets_file_map = {
    # These secret will be retrieved from the respective files and uploaded
    # to AWS Secrets Manager:
    MY_SAMPLE_1_username = "./.secrets/mysample1-creds.yml:username
    MY_SAMPLE_1_password = "./.secrets/mysample1-creds.yml:password
    MY_SAMPLE_2_username = "./.secrets/mysample2-creds.json:username
    MY_SAMPLE_2_password = "./.secrets/mysample2-creds.json:password

    # Because the paths starts with `arn://`, these secret are assumed to be
    # already in AWS Secrets Manager and will not be uploaded:
    SAMPLE_aws_access_key_id     = "arn:aws:secretsmanager:us-east-1::secret:aws_access_key_id-sqQDPG"
    SAMPLE_aws_secret_access_key = "arn:aws:secretsmanager:us-east-1::secret:aws_secret_access_key-adf13"
  }
```

**Outputs from sample:**

```hcl
{
    # Newly created AWS Secrets Manager secrets:
    MY_SAMPLE_1_username = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_1_username-adf13"
    MY_SAMPLE_1_password = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_1_password-adf13"
    MY_SAMPLE_2_username = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_2_username-adf13"
    MY_SAMPLE_2_password = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_2_password-adf13"

    # Secrets IDs passed through with no change:
    SAMPLE_aws_access_key_id     = "arn:aws:secretsmanager:us-east-1::secret:aws_access_key_id-adf13"
    SAMPLE_aws_secret_access_key = "arn:aws:secretsmanager:us-east-1::secret:aws_secret_access_key-adf13"
}
```


---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [alb.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/alb.tf)
* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [py-script-upload.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/py-script-upload.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [python-zip.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/python-zip.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
