
# AWS ECS-Cluster

`/components/aws/ecs-cluster`

## Overview


ECS, or EC2 Container Service, is able to run docker containers natively in AWS cloud. While the module can support classic EC2-based and Fargate,
features, this module generally prefers "ECS Fargete", which allows dynamic launching of docker containers with no always-on cost and no servers
to manage or pay for when tasks are not running.

Use in combination with the `ECS-Task` component.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| ec2\_instance\_count | n/a | `number` | `0` | no |
| ec2\_instance\_type | n/a | `string` | `"m4.xlarge"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecs\_cluster\_arn | n/a |
| ecs\_cluster\_name | n/a |
| ecs\_instance\_role | n/a |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [iam.tf](iam.tf)
* [main.tf](main.tf)
* [outputs.tf](outputs.tf)
* [variables.tf](variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
