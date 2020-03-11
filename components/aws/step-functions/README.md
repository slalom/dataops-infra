
# AWS Step-Functions

`/components/aws/step-functions`

## Overview


AWS Step Functions is a service provided by Amazon Web Services that makes it easier to orchestrate multiple AWS services
to accomplish tasks. Step Functions allows you to create steps in a process where the output of one step becomes the input
for another step.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| account\_id | n/a | `string` | n/a | yes |
| state\_machine\_definition | n/a | `string` | n/a | yes |
| state\_machine\_name | n/a | `string` | n/a | yes |
| resource\_tags | n/a | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| summary | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
