
# AWS ECR

`/components/aws/ecr`

## Overview


ECR (Elastic Compute Repository) is the private-hosted AWS equivalent of DockerHub. ECR allows you to securely publish docker images which
should not be accessible to external users.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| image\_name | n/a | `any` | n/a | yes |
| repository\_name | n/a | `any` | n/a | yes |
| resource\_tags | n/a | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecr\_image\_url | n/a |
| ecr\_repo\_arn | n/a |
| ecr\_repo\_root | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
