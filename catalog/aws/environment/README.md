
# AWS Environment

`/catalog/aws/environment`

## Overview


The environment module sets up common infrastrcuture like VPCs and network subnets. The `envrionment` output
from this module is designed to be passed easily to downstream modules, streamlining the reuse of these core components.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aws\_profile | The name of the AWS profile to use. Optional unless set at the main AWS provider level, in which case it is required. | `string` | n/a | yes |
| aws\_region | Optional, used for multi-region deployments. Overrides the contextual AWS region with the region code provided. | `any` | n/a | yes |
| environment | Standard `environment` module input. (Ignored for the `environment` module.) | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| secrets\_folder | Path to the secrets folder (used when initializing the AWS provider.) | `string` | n/a | yes |
| disabled | As a workaround for unsupported 'count' feature in terraform modules, this switch can be used to disable the module entirely. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_credentials\_file | Path to AWS credentials file for the project. |
| environment | The `environment` object to be passed as a standard input to other Infrastructure Catalog modules. |
| is\_windows\_host | True if running on a Windows machine, otherwise False. |
| ssh\_private\_key\_filename | Path to private key for SSH connections. |
| ssh\_public\_key\_filename | Path to public key for SSH connections. |
| summary | Summary of resources created by this module. |
| user\_home | Path to the admin user's home directory. |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](main.tf)
* [outputs.tf](outputs.tf)
* [variables.tf](variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
