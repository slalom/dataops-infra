
# AWS DBT

`/catalog/aws/dbt`

## Overview


DBT (Data Built Tool) is a CI/CD and DevOps-friendly platform for automating data transformations. More info at [www.getdbt.com](https://www.getdbt.com).

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| admin\_cidr | Optional. The range of IP addresses which should be able to access the DBT instance. Defaults to the local user's current IP. | `list` | `[]` | no |
| container\_entrypoint | Optional. Overrides the docker image entrypoint. | `any` | `null` | no |
| container\_image | Optional. A docker image to override the default image. | `string` | `"slalomggp/dataops"` | no |
| container\_num\_cores | Optional. Overrides the number of CPU cores used. | `number` | `4` | no |
| container\_ram\_gb | Optional. Overrides the RAM used (in GB). | `number` | `16` | no |
| dbt\_project\_git\_repo | Optional. A git repo to download to the local image which contains DBT transforms information. | `string` | `"git+https://github.com/slalom-ggp/dataops-project-template.git"` | no |
| dbt\_run\_command | Optional. The default command to run when executing DBT. | `string` | `null` | no |
| environment\_secrets | Mapping of environment variable names to secret manager ARNs.<br>e.g. arn:aws:secretsmanager:[aws\_region]:[aws\_account]:secret:prod/ECSRunner/AWS\_SECRET\_ACCESS\_KEY | `map(string)` | `{}` | no |
| environment\_vars | Mapping of environment variable names to their values. | `map(string)` | `{}` | no |
| scheduled\_refresh\_interval | A rate string, e.g. '5 minutes'. This is in addition to any other scheduled executions. | `string` | `null` | no |
| scheduled\_refresh\_times | A list of schedule strings in 6-part cron notation. For help creating cron schedule codes: https://crontab.guru | `list(string)` | `[]` | no |
| scheduled\_timezone | The timezone code with which to evaluate execution schedule(s). | `string` | `"PT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| summary | Summary of resources created by this module. |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/dbt/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/dbt/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/dbt/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
