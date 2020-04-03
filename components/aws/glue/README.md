
# AWS Glue

`/components/aws/glue`

## Overview


Glue is AWS's fully managed extract, transform, and load (ETL) service. A Glue job can be used job to run ETL Python scripts.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| job\_type | Type of Glue job (Spark or Python Shell). | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| s3\_destination\_bucket\_name | S3 destination bucket for Glue transformation job. | `string` | n/a | yes |
| s3\_script\_bucket\_name | S3 script bucket for Glue transformation job. | `string` | n/a | yes |
| s3\_source\_bucket\_name | S3 source bucket for Glue transformation job. | `string` | n/a | yes |
| script\_path | Path to Glue script. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| glue\_job\_name | The name of the Glue job. |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
