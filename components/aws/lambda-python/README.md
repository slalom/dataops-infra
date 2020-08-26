---
parent: Infrastructure Components
title: AWS Lambda-Python
nav_exclude: false
---
# AWS Lambda-Python

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/lambda-python?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/lambda-python)

## Overview


AWS Lambda is a platform which enables serverless execution of arbitrary functions. This module specifically focuses on the
Python implementatin of Lambda functions. Given a path to a folder of one or more python fyles, this module takes care of
packaging the python code into a zip and uploading to a new Lambda Function in AWS. The module can also be configured with
S3-based triggers, to run the function automatically whenever a file is landed in a specific S3 path.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- aws

- random

- null

- archive

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

### upload\_to\_s3

Description: True to upload source code to S3, False to upload inline with the Lambda function.

Type: `bool`

### functions

Description: A map of function names to create and an object with properties describing the function.

Example:
  functions = [
    "fn\_log" = {
      description = "Add an entry to the log whenever a file is created."
      handler     = "main.lambda\_handler"
      environment = {}
      secrets     = {}
    }
  ]

Type:

```hcl
map(object({
    description = string
    handler     = string
    environment = map(string)
    secrets     = map(string)
  }))
```

## Optional Inputs

The following input variables are optional (have default values):

### runtime

Description: The python runtime, e.g. `python3.8`.

Type: `string`

Default: `"python3.8"`

### pip\_path

Description: The path to a local pip executable, used to package python dependencies.

Type: `string`

Default: `"pip3"`

### timeout\_seconds

Description: The amount of time which can pass before the function will timeout and fail execution.

Type: `number`

Default: `300`

### lambda\_source\_folder

Description: Local path to a folder containing the lambda source code.

Type: `string`

Default: `"resources/fn_log"`

### upload\_to\_s3\_path

Description: S3 Path to where the source code zip should be uploaded.
Use in combination with: `upload_to_s3 = true`

Type: `string`

Default: `null`

### s3\_trigger\_bucket

Description: The name of an S3 bucket which will trigger this Lambda function.

Type: `string`

Default: `null`

### s3\_triggers

Description: A list of objects describing the S3 trigger action.

Example:
  s3\_triggers = [
    {
      function\_name = "fn\_log"
      s3\_bucket     = "\*"
      s3\_path       = "\*"
    }
  ]

Type:

```hcl
list(object({
    function_name = string
    s3_bucket     = string
    s3_path       = string
  }))
```

Default: `null`

## Outputs

The following outputs are exported:

### build\_temp\_dir

Description: Full path to the local folder used to build the python package.

### function\_ids

Description: A map of function names to the unique function ID (ARN).

### lambda\_iam\_role

Description: The IAM role used by the lambda function to access resources. Can be used to grant
additional permissions to the role.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/lambda-python/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/lambda-python/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/lambda-python/outputs.tf)
* [python-zip.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/lambda-python/python-zip.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/lambda-python/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
