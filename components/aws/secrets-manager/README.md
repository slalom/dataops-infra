# AWS Secrets Manager

`components/aws/secrets-manager`

## Overview

This module takes as input a set of maps from variable names to secrets locations (in YAML or JSON). The module uploads those secrets to AWS Secrets Manager and returns the same map pointing to the IDs of new AWS Secrets manager locations. Those IDs (aka ARNs) can then safely be handed on to other resources which required access to those secrets.

**Usage Notes:**

* Any secrets locations which are already pointing to AWS secrets will simply be passed back through to the output with no changes.
* For security reasons, this module does not accept inputs for secrets using the clear text of the secrets themselves. To properly use this module, first save the secrets to a YAML or JSON file which is excluded from source control.

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

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| kms\_key\_id | Optional. A valid KMS key ID to use for encrypting the secret values. If omitted, the default KMS key will be applied. | `any` | n/a | yes |
| name\_prefix | Common variable: the name prefix to use in all created resources. | `string` | n/a | yes |
| resource\_tags | Common variable: the resource tags to use in all created resources. | `map` | n/a | yes |
| secrets\_map | A map between secret names and their locations.<br><br>The location can be:<br><br>  - ID of an existing Secrets Manager secret (`arn:aws:secretsmanager:...`)<br>   - String with the local secrets file name and property names separated by `:` (`path/to/file.yml:my_key_name`)." | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| secrets\_ids | n/a |
| summary | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
