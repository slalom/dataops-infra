
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
| ec2\_instance\_count | Optional. Number of 'always-on' EC2 instances. (Default is 0, meaning no always-on EC2 resources.). | `number` | `0` | no |
| ec2\_instance\_type | Optional. Overrides default instance type if using always-on EC2 instances (i.e. `ec2_instance_count` > 0). | `string` | `"m4.xlarge"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecs\_cluster\_arn | The unique ID (ARN) of the ECS cluster. |
| ecs\_cluster\_name | The name of the ECS cluster. |
| ecs\_instance\_role | The name of the IAM instance role used by the ECS cluster. (Can be used to grant additional permissions.) |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/ecs-cluster/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/ecs-cluster/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/ecs-cluster/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/ecs-cluster/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
