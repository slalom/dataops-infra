
# AWS Step-Functions

`/components/aws/step-functions`

## Overview


AWS Step Functions is a service provided by Amazon Web Services that makes it easier to orchestrate multiple AWS services
to accomplish tasks. Step Functions allows you to create steps in a process where the output of one step becomes the input
for another step.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| extracts\_store\_bucket | Bucket which contains transformed training and scoring data. | `string` | n/a | yes |
| feature\_store\_bucket | Bucket which contains pre-transformed training data and scoring data. | `string` | n/a | yes |
| lambda\_functions | Map of function names to ARNs. Used to ensure state machine access to functions. | `map(string)` | n/a | yes |
| model\_store\_bucket | Bucket which contains model objects. | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| output\_store\_bucket | Bucket which contains batch transformation output. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| state\_machine\_definition | The JSON definition of the state machine to be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| iam\_role\_arn | The IAM role used by the step function to access resources. Can be used to grant<br>additional permissions to the role. |
| state\_machine\_arn | The State Machine arn. |
| state\_machine\_name | The State Machine name. |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
