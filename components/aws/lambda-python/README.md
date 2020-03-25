
# AWS Lambda-Python

`/components/aws/lambda-python`

## Overview


AWS Lambda is a platform which enables serverless execution of arbitrary functions. This module specifically focuses on the
Python implementatin of Lambda functions. Given a path to a folder of one or more python fyles, this module takes care of
packaging the python code into a zip and uploading to a new Lambda Function in AWS. The module can also be configured with
S3-based triggers, to run the function automatically whenever a file is landed in a specific S3 path.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| s3\_trigger\_bucket | The name of an S3 bucket which will trigger this Lambda function. | `string` | n/a | yes |
| upload\_to\_s3 | n/a | `bool` | n/a | yes |
| upload\_to\_s3\_path | S3 Path to where the source code zip should be uploaded.<br>Use in combination with: `upload_to_s3 = true` | `string` | n/a | yes |
| lambda\_source\_folder | Local path to a folder containing the lambda source code. | `string` | `"resources/fn_log"` | no |
| pip\_path | The path to a local pip executable, used to package python dependencies. | `string` | `"pip3"` | no |
| runtime | The python runtime, e.g. `python3.8`. | `string` | `"python3.8"` | no |
| s3\_triggers | A list of objects describing the S3 trigger action.<br><br>Example:   s3\_triggers = [     {       function\_name = "fn\_log"       s3\_bucket     = "\*"       s3\_path       = "\*"     }   ] | <pre>list(object({<br>    function_name = string<br>    s3_bucket     = string<br>    s3_path       = string<br>  }))</pre> | `[]` | no |
| timeout\_seconds | The amount of time which can pass before the function will timeout and fail execution. | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| build\_temp\_dir | Full path to the local folder used to build the python package. |
| function\_ids | n/a |
| lambda\_iam\_role | n/a |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [iam.tf](iam.tf)
* [main.tf](main.tf)
* [outputs.tf](outputs.tf)
* [python-zip.tf](python-zip.tf)
* [variables.tf](variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
