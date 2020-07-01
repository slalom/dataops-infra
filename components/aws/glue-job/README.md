
# AWS Glue-Job

`/components/aws/glue-job`

## Overview


Glue is AWS's fully managed extract, transform, and load (ETL) service. A Glue job can be used job to run ETL Python scripts.

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| s3\_destination\_bucket\_name | S3 destination bucket for Glue transformation job. | `string` | n/a | yes |
| s3\_script\_bucket\_name | S3 script bucket for Glue transformation job. | `string` | n/a | yes |
| s3\_source\_bucket\_name | S3 source bucket for Glue transformation job. | `string` | n/a | yes |
| local\_script\_path | Optional. If provided, the local script will automatically be uploaded to the remote bucket path. In not provided, will use s3\_script\_path instead. | `string` | `null` | no |
| max\_instances | The maximum number of simultaneous executions. | `number` | `10` | no |
| num\_workers | Min 2. The number or worker nodes to dedicate to each instance of the job. | `number` | `2` | no |
| s3\_script\_path | Ignored if `local_script_path` is provided. Otherwise, the file at this path will be used for the Glue script. | `string` | `null` | no |
| with\_spark | (Default=True). True for standard PySpark Glue job. False for Python Shell. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| glue\_job\_name | The name of the Glue job. |
| summary | Summary of Glue resources created. |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/glue-job/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/glue-job/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/glue-job/outputs.tf)
* [py-script-upload.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/glue-job/py-script-upload.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/glue-job/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
