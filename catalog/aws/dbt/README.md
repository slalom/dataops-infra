
# AWS DBT

`/catalog/aws/dbt`

## Overview


DBT (Data Built Tool) is a CI/CD and DevOps-friendly platform for automating data transformations. More info at [www.getdbt.com](https://www.getdbt.com).

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| container\_entrypoint | n/a | `any` | n/a | yes |
| dbt\_run\_command | n/a | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| scheduled\_refresh\_interval | A rate string, e.g. '5 minutes'. This is in addition to any other scheduled executions. | `string` | n/a | yes |
| admin\_cidr | n/a | `list` | `[]` | no |
| container\_image | n/a | `string` | `"slalomggp/dataops"` | no |
| container\_num\_cores | n/a | `number` | `4` | no |
| container\_ram\_gb | n/a | `number` | `16` | no |
| dbt\_project\_git\_repo | n/a | `string` | `"git+https://github.com/slalom-ggp/dataops-project-template.git"` | no |
| environment\_secrets | Mapping of environment variable names to secret manager ARNs.<br>e.g. arn:aws:secretsmanager:[aws\_region]:[aws\_account]:secret:prod/ECSRunner/AWS\_SECRET\_ACCESS\_KEY | `map(string)` | `{}` | no |
| environment\_vars | Mapping of environment variable names to their values. | `map(string)` | `{}` | no |
| scheduled\_refresh\_times | A list of schedule strings in 6-part cron notation. For help creating cron schedule codes: https://crontab.guru | `list(string)` | `[]` | no |
| scheduled\_timezone | n/a | `string` | `"PT"` | no |

## Outputs

| Name | Description |
|------|-------------|
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
