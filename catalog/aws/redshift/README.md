
# AWS Redshift

`/catalog/aws/redshift`

## Overview


Redshift is an AWS database platform which applies MPP (Massively-Parallel-Processing) principles to big data workloads in the cloud.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| admin\_password | Must be 8 characters long. | `string` | n/a | yes |
| elastic\_ip | n/a | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| kms\_key\_id | n/a | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| s3\_logging\_bucket | n/a | `string` | n/a | yes |
| s3\_logging\_path | n/a | `string` | n/a | yes |
| jdbc\_port | n/a | `number` | `5439` | no |
| node\_type | Enter the desired node type. The default and cheapest option is 'dc2.large' @ ~$0.25/hr  (https://aws.amazon.com/redshift/pricing/) | `string` | `"dc2.large"` | no |
| num\_nodes | n/a | `number` | `1` | no |
| skip\_final\_snapshot | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | n/a |
| summary | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
