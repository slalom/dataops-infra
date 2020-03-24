
# AWS ECR

`/components/aws/ecr`

## Overview


ECR (Elastic Compute Repository) is the private-hosted AWS equivalent of DockerHub. ECR allows you to securely publish docker images which
should not be accessible to external users.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| image\_name | Required. The default name for the docker image. (Will be concatenated with `repository_name`.) | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| repository\_name | Required. A name for the ECR respository. (Will be concatenated with `image_name`.) | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ecr\_image\_url | The full path to the ECR image, including image name. |
| ecr\_repo\_arn | The unique ID (ARN) of the ECR repo. |
| ecr\_repo\_root | The path to the ECR repo, excluding image name. |

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
