
# AWS Airflow

`/catalog/aws/airflow`

## Overview


Airflow is an open source platform to programmatically author, schedule and monitor workflows. More information here: [airflow.apache.org](https://airflow.apache.org/)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| container\_command | The command to run on the Airflow container. | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| github\_repo\_ref | The git repo reference to clone onto the airflow server | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| container\_image | Optional. Overrides the docker image used for Airflow execution. | `string` | `"airflow"` | no |
| container\_num\_cores | Optional. The number of CPU cores. | `number` | `2` | no |
| container\_ram\_gb | Optional. The amount of RAM to use, in GB. | `number` | `4` | no |
| environment\_secrets | A map of environment variable secrets to pass to the airflow image. Each secret value should be either a<br>Secrets Manager URI or a local JSON or YAML file reference in the form `/path/to/file.yml:name_of_secret`. | `map(string)` | `{}` | no |
| environment\_vars | A map of environment variables to pass to the Airflow image. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| airflow\_url | Link to the airflow web UI. |
| logging\_url | Link to Airflow logs in Cloudwatch. |
| server\_launch\_cli | Command to launch the Airflow web server via ECS. |
| summary | Summary of resources created by this module. |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/airflow/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/airflow/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/airflow/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
