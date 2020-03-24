
# AWS Redshift

`/catalog/aws/redshift`

## Overview


Redshift is an AWS database platform which applies MPP (Massively-Parallel-Processing) principles to big data workloads in the cloud.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| admin\_password | The initial admin password. Must be 8 characters long. | `string` | n/a | yes |
| elastic\_ip | Optional. An Elastic IP endpoint which will be used to for routing incoming traffic. | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| kms\_key\_id | Optional. The ARN for the KMS encryption key used in cluster encryption. | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| s3\_logging\_bucket | Optional. An S3 bucket to use for log collection. | `string` | n/a | yes |
| s3\_logging\_path | Required if `s3_logging_bucket` is set. The path within the S3 bucket to use for log storage. | `string` | n/a | yes |
| jdbc\_port | Optional. Overrides the default JDBC port for incoming SQL connections. | `number` | `5439` | no |
| node\_type | Enter the desired node type. The default and cheapest option is 'dc2.large' @ ~$0.25/hr, ~$180/mo (https://aws.amazon.com/redshift/pricing/) | `string` | `"dc2.large"` | no |
| num\_nodes | Optional (default=1). The number of Redshift nodes to use. | `number` | `1` | no |
| skip\_final\_snapshot | If true, will allow terraform to destroy the RDS cluster without performing a final backup. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | The Redshift connection endpoint for the new server. |
| summary | Summary of resources created by this module. |

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
