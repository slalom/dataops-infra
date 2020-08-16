
# AWS ECS-Cluster

`/components/aws/ecs-cluster`

## Overview


Flag --no-sort has been deprecated, use '--sort=false' instead
ECS, or EC2 Container Service, is able to run docker containers natively in AWS cloud. While the module can support classic EC2-based and Fargate,
features, this module generally prefers "ECS Fargete", which allows dynamic launching of docker containers with no always-on cost and no servers
to manage or pay for when tasks are not running.

Use in combination with the `ECS-Task` component.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- random

- aws

## Required Inputs

The following input variables are required:

### name\_prefix

Description: Standard `name_prefix` module input.

Type: `string`

### environment

Description: Standard `environment` module input.

Type:

```hcl
object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
```

### resource\_tags

Description: Standard `resource_tags` module input.

Type: `map(string)`

## Optional Inputs

The following input variables are optional (have default values):

### ec2\_instance\_type

Description: Optional. Overrides default instance type if using always-on EC2 instances (i.e. `ec2_instance_count` > 0).

Type: `string`

Default: `"m4.xlarge"`

### ec2\_instance\_count

Description: Optional. Number of 'always-on' EC2 instances. (Default is 0, meaning no always-on EC2 resources.).

Type: `number`

Default: `0`

## Outputs

The following outputs are exported:

### ecs\_cluster\_name

Description: The name of the ECS cluster.

### ecs\_cluster\_arn

Description: The unique ID (ARN) of the ECS cluster.

### ecs\_instance\_role

Description: The name of the IAM instance role used by the ECS cluster. (Can be used to grant additional permissions.)

---------------------

## Source Files

_Source code for this module is available using the links below._

* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecs-cluster/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecs-cluster/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecs-cluster/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecs-cluster/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
