
# AWS Airflow

`/catalog/aws/airflow`

## Overview


Airflow is an open source platform to programmatically author, schedule and monitor workflows. More information here: [airflow.apache.org](https://airflow.apache.org/)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| container\_command | n/a | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| github\_repo\_ref | The git repo reference to clone onto the airflow server | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
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

## Source Files

_Source code for this module is available using the links below._

* [main.tf](main.tf)
* [outputs.tf](outputs.tf)
* [variables.tf](variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
