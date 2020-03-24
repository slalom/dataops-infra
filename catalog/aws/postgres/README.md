
# AWS Postgres

`/catalog/aws/postgres`

## Overview


Deploys a Postgres server running on RDS.

* NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| admin\_password | Must be 8 characters long. | `string` | n/a | yes |
| admin\_username | n/a | `string` | n/a | yes |
| elastic\_ip | n/a | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| kms\_key\_id | n/a | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| s3\_logging\_bucket | n/a | `string` | n/a | yes |
| s3\_logging\_path | n/a | `string` | n/a | yes |
| identifier | n/a | `string` | `"rds-postgres-db"` | no |
| instance\_class | Enter the desired node type. The default and cheapest option is 'db.t2.micro' @ ~$0.017/hr  (https://aws.amazon.com/rds/mysql/pricing/ ) | `string` | `"db.t2.micro"` | no |
| jdbc\_port | n/a | `number` | `5432` | no |
| postgres\_version | n/a | `string` | `"11.5"` | no |
| skip\_final\_snapshot | n/a | `bool` | `false` | no |
| storage\_size\_in\_gb | The allocated storage value is denoted in GB | `string` | `"10"` | no |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | n/a |
| summary | n/a |

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
