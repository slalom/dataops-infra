
# AWS Airflow

`/catalog/aws/airflow`

## Overview


Airflow is an open source platform to programmatically author, schedule and monitor workflows. More information here: [airflow.apache.org](https://airflow.apache.org/)

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| container\_command | Catalog Variables | `string` | n/a | yes |
| environment | n/a | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| github\_repo\_ref | The git repo reference to clone onto the airflow server | `string` | n/a | yes |
| name\_prefix | Common Variables: | `string` | n/a | yes |
| resource\_tags | n/a | `map(string)` | n/a | yes |
| container\_image | n/a | `string` | `"airflow"` | no |
| container\_num\_cores | n/a | `number` | `2` | no |
| container\_ram\_gb | n/a | `number` | `4` | no |
| environment\_secrets | n/a | `map(string)` | `{}` | no |
| environment\_vars | n/a | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| airflow\_url | n/a |
| logging\_url | n/a |
| server\_launch\_cli | n/a |
| summary | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
