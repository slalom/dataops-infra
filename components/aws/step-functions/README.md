
# AWS Step-Functions

`/components/aws/step-functions`

## Overview


AWS Step Functions is a service provided by Amazon Web Services that makes it easier to orchestrate multiple AWS services
to accomplish tasks. Step Functions allows you to create steps in a process where the output of one step becomes the input
for another step.

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| state\_machine\_definition | The JSON definition of the state machine to be created. | `string` | n/a | yes |
| ecs\_tasks | List of ECS tasks, to ensure state machine access permissions. | `list(string)` | `[]` | no |
| lambda\_functions | Map of function names to ARNs. Used to ensure state machine access to functions. | `map(string)` | `{}` | no |
| writeable\_buckets | Buckets which should be granted write access. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam\_role\_arn | The IAM role used by the step function to access resources. Can be used to grant<br>additional permissions to the role. |
| state\_machine\_arn | The State Machine arn. |
| state\_machine\_name | The State Machine name. |
| state\_machine\_url |  |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/step-functions/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/step-functions/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/step-functions/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/step-functions/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
