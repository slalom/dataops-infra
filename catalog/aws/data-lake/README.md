
# AWS Data-Lake

`/catalog/aws/data-lake`

## Overview


This data lake implementation creates three buckets, one each for data, logging, and metadata. The data lake also supports lambda functions which can
trigger automatically when new content is added.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| data\_bucket\_override | Optionally, you can override the default data bucket with a bucket that already exists. | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| lambda\_python\_source | Local path to a folder containing the lambda source code (e.g. 'resources/fn\_log') | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| s3\_triggers | List of S3 triggers objects, for example:<pre>[{<br>  function_name       = "fn_log"<br>  triggering_path     = "*"<br>  lambda_handler      = "main.lambda_handler"<br>  environment_vars    = {}<br>  environment_secrets = {}<br>}]</pre> | <pre>map(<br>    # function_name as map key<br>    object({<br>      triggering_path     = string<br>      lambda_handler      = string<br>      environment_vars    = map(string)<br>      environment_secrets = map(string)<br>    })<br>  )</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3\_data\_bucket | The S3 bucket used for data storage. |
| s3\_logging\_bucket | The S3 bucket used for log file storage. |
| s3\_metadata\_bucket | The S3 bucket used for metadata file storage. |
| summary | Summary of resources created by this module. |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](main.tf)
* [outputs.tf](outputs.tf)
* [variables.tf](variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
