---
parent: Infrastructure Components
title: AWS ECS-Task
nav_exclude: false
---
# AWS ECS-Task

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/ecs-task?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/ecs-task)

## Overview


ECS, or EC2 Container Service, is able to run docker containers natively in AWS cloud. While the module can support classic EC2-based and Fargate,
features, this module generally prefers "ECS Fargete", which allows dynamic launching of docker containers with no always-on cost and no servers
to manage or pay for when tasks are not running.

Use in combination with the `ECS-Cluster` component.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- aws

- random

- null

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

### container\_image

Description: Examples: 'python:3.8', [aws\_account\_id].dkr.ecr.[aws\_region].amazonaws.com/[byo\_model\_repo\_name]

Type: `string`

### ecs\_cluster\_name

Description: The name of the ECS Cluster to use.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### always\_on

Description: True to create an ECS Service with a single 'always-on' task instance.

Type: `bool`

Default: `false`

### admin\_ports

Description: A list of admin ports (to be governed by `admin_cidr`).

Type: `list(string)`

Default:

```json
[
  "8080"
]
```

### app\_ports

Description: A list of app ports (will be governed by `app_cidr`).

Type: `list(string)`

Default:

```json
[
  "8080"
]
```

### container\_command

Description: Optional. Overrides 'command' for the image.

Type: `any`

Default: `null`

### container\_entrypoint

Description: Optional. Overrides the 'entrypoint' for the image.

Type: `any`

Default: `null`

### container\_name

Description: Optional. Overrides the name of the default container.

Type: `string`

Default: `"DefaultContainer"`

### container\_num\_cores

Description: The number of CPU cores to dedicate to the container.

Type: `string`

Default: `"4"`

### container\_ram\_gb

Description: The amount of RAM to dedicate to the container.

Type: `string`

Default: `"8"`

### ecs\_launch\_type

Description: 'FARGATE' or 'Standard'

Type: `string`

Default: `"FARGATE"`

### environment\_secrets

Description: Mapping of environment variable names to secret manager ARNs or local file secrets. Examples:
 - arn:aws:secretsmanager:[aws\_region]:[aws\_account]:secret:prod/ECSRunner/AWS\_SECRET\_ACCESS\_KEY
 - path/to/file.json:MY\_KEY\_NAME\_1
 - path/to/file.yml:MY\_KEY\_NAME\_2

Type: `map(string)`

Default: `{}`

### environment\_vars

Description: Mapping of environment variable names to their values.

Type: `map(string)`

Default: `{}`

### load\_balancer\_arn

Description: Required only if `use_load_balancer` = True. The load balancer to use for inbound traffic.

Type: `string`

Default: `null`

### permitted\_s3\_buckets

Description: A list of bucket names, to which the ECS task will be granted read/write access.

Type: `list(string)`

Default: `null`

### schedules

Description: A lists of scheduled execution times.

Type: `set(string)`

Default: `[]`

### secrets\_manager\_kms\_key\_id

Description: Optional. Overrides the KMS key used when storing secrets in AWS Secrets Manager.

Type: `string`

Default: `null`

### use\_load\_balancer

Description: True to receive inbound traffic from the load balancer specified in `load_balancer_arn`.

Type: `bool`

Default: `false`

### use\_fargate

Description: True to use Fargate for task execution (default), False to use EC2 (classic).

Type: `bool`

Default: `true`

### use\_private\_subnet

Description: If True, tasks will use a private subnet and will require a NAT gateway to pull the docker
image, and for any outbound traffic. If False, tasks will use a public subnet and will not
require a NAT gateway.

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### cloudwatch\_log\_group\_name

Description: Name of Cloudwatch log group used for this task.

### ecs\_checklogs\_cli

Description: Command-ling string used to print Cloudwatch logs locally.

### ecs\_container\_name

Description: The name of the task's primary container.

### ecs\_task\_execution\_role

Description: An IAM role which has access to execute the ECS Task.

### ecs\_logging\_url

Description: Link to Cloudwatch logs for this task.

### ecs\_runtask\_cli

Description: Command-line string used to trigger on-demand execution of the Task.

### ecs\_task\_name

Description: The name of the ECS task.

### ecs\_security\_group

Description: The name of the EC2 security group used by ECS.

### load\_balancer\_arn

Description: The unique ID (ARN) of the load balancer (if applicable).

### load\_balancer\_dns

Description: The DNS of the load balancer (if applicable).

### subnets

Description: A list of subnets used for task execution.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [alb.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecs-task/alb.tf)
* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecs-task/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecs-task/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecs-task/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ecs-task/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
