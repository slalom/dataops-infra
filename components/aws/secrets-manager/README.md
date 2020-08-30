---
parent: Infrastructure Components
title: AWS Secrets-Manager
nav_exclude: false
---
# AWS Secrets-Manager

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/secrets-manager?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/secrets-manager)

## Overview


This module takes as input a set of maps from variable names to secrets locations (in YAML or
JSON). The module uploads those secrets to AWS Secrets Manager and returns the same map pointing
to the IDs of new AWS Secrets manager locations. Those IDs (aka ARNs) can then safely be handed
on to other resources which required access to those secrets.

\*\*Usage Notes:\*\*

* Any secrets locations which are already pointing to AWS secrets will simply be passed back through to the output with no changes.
* For security reasons, this module does not accept inputs for secrets using the clear text of the secrets themselves. To properly use this module, first save the secrets to a YAML or JSON file which is excluded from source control.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- random

- aws

## Required Inputs

The following input variables are required:

### name\_prefix

Description: Standard `name_prefix` module input.

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

## Optional Inputs

The following input variables are optional (have default values):

### secrets\_map

Description: A map between secret names and their locations.

The location can be:

  - ID of an existing Secrets Manager secret (`arn:aws:secretsmanager:...`)

  - String with the local secrets file name and property names separated by `:` (`path/to/file.yml:my_key_name`)."

Type: `map(string)`

Default: `{}`

### kms\_key\_id

Description: Optional. A valid KMS key ID to use for encrypting the secret values. If omitted, the default KMS key will be applied.

Type: `any`

Default: `null`

## Outputs

The following outputs are exported:

### summary

Description: Summary of resources created by this module.

### secrets\_ids

Description: A map of secrets names to each secret's unique ID within AWS Secrets Manager.

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

* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/secrets-manager/outputs.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/secrets-manager/main.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/secrets-manager/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
