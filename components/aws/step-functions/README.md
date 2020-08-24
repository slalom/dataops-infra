---
parent: Infrastructure Components
title: AWS Step-Functions
nav_exclude: false
---
# AWS Step-Functions

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/step-functions?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/step-functions)

## Overview


AWS Step Functions is a service provided by Amazon Web Services that makes it easier to orchestrate multiple AWS services
to accomplish tasks. Step Functions allows you to create steps in a process where the output of one step becomes the input
for another step.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- random

- null

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

### state\_machine\_definition

Description: The JSON definition of the state machine to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### writeable\_buckets

Description: Buckets which should be granted write access.

Type: `list(string)`

Default: `[]`

### lambda\_functions

Description: Map of function names to ARNs. Used to ensure state machine access to functions.

Type: `map(string)`

Default: `{}`

### ecs\_tasks

Description: List of ECS tasks, to ensure state machine access permissions.

Type: `list(string)`

Default: `[]`

## Outputs

The following outputs are exported:

### state\_machine\_name

Description: The State Machine name.

### state\_machine\_arn

Description: The State Machine arn.

### iam\_role\_arn

Description: The IAM role used by the step function to access resources. Can be used to grant
additional permissions to the role.

### state\_machine\_url

Description:

---------------------

## Source Files

_Source code for this module is available using the links below._

* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/step-functions/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/step-functions/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/step-functions/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/step-functions/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
