---
parent: Infrastructure Catalog
title: AWS Data-Lake
nav_exclude: false
---
# AWS Data-Lake

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/aws/data-lake?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/aws/data-lake)

## Overview


This data lake implementation creates three buckets, one each for data, logging, and metadata. The data lake also supports lambda functions which can
trigger automatically when new content is added.

* Designed to be used in combination with the `aws/data-lake-users` module.
* To add SFTP protocol support, combine this module with the `aws/sftp` module.

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

### data\_bucket\_override

Description: Optionally, you can override the default data bucket with a bucket that already exists.

Type: `string`

Default: `null`

### lambda\_python\_source

Description: Local path to a folder containing the lambda source code (e.g. 'resources/fn\_log')

Type: `string`

Default: `null`

### s3\_triggers

Description: List of S3 triggers objects, for example:
```
[{
  function_name       = "fn_log"
  triggering_path     = "*"
  lambda_handler      = "main.lambda_handler"
  environment_vars    = {}
  environment_secrets = {}
}]
```

Type:

```hcl
map(
    # function_name as map key
    object({
      triggering_path     = string
      lambda_handler      = string
      environment_vars    = map(string)
      environment_secrets = map(string)
    })
  )
```

Default: `{}`

## Outputs

The following outputs are exported:

### summary

Description: Summary of resources created by this module.

### s3\_data\_bucket

Description: The S3 bucket used for data storage.

### s3\_metadata\_bucket

Description: The S3 bucket used for metadata file storage.

### s3\_logging\_bucket

Description: The S3 bucket used for log file storage.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/data-lake/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/data-lake/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/data-lake/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
