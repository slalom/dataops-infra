
# AWS Redshift

`/components/aws/redshift`

## Overview


This is the underlying technical component which supports the Redshift catalog module.

NOTE: Requires AWS policy 'AmazonRedshiftFullAccess' on the terraform account

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| admin\_password | The initial admin password. Must be 8 characters long. | `string` | n/a | yes |
| elastic\_ip | Optional. An Elastic IP endpoint which will be used to for routing incoming traffic. | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| identifier | Optional. The unique identifier for the redshift cluster. | `string` | n/a | yes |
| kms\_key\_id | Optional. The ARN for the KMS encryption key used in cluster encryption. | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| s3\_logging\_bucket | Optional. An S3 bucket to use for log collection. | `string` | n/a | yes |
| s3\_logging\_path | Required if `s3_logging_bucket` is set. The path within the S3 bucket to use for log storage. | `string` | n/a | yes |
| admin\_username | Optional (default=''). The initial admin username. | `string` | `"rsadmin"` | no |
| database\_name | The name of the initial Redshift database to be created. | `string` | `"redshift_db"` | no |
| jdbc\_cidr | List of CIDR blocks which should be allowed to connect to the instance on the JDBC port. | `list(string)` | `[]` | no |
| jdbc\_port | Optional. Overrides the default JDBC port for incoming SQL connections. | `number` | `5439` | no |
| node\_type | Enter the desired node type. The default and cheapest option is 'dc2.large' @ ~$0.25/hr, ~$180/mo (https://aws.amazon.com/redshift/pricing/) | `string` | `"dc2.large"` | no |
| num\_nodes | Optional (default=1). The number of Redshift nodes to use. | `number` | `1` | no |
| skip\_final\_snapshot | If true, will allow terraform to destroy the RDS cluster without performing a final backup. | `bool` | `false` | no |
| whitelist\_terraform\_ip | True to allow the terraform user to connect to the DB instance. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | The connection endpoint for the new Redshift instance. |
| summary | Summary of resources created by this module. |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/redshift/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/redshift/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/redshift/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
