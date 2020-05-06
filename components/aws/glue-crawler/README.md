
# AWS Glue-Crawler

`/components/aws/glue-crawler`

## Overview


Glue is AWS's fully managed extract, transform, and load (ETL) service.
A Glue crawler is used to access a data store and create table definitions.
This can be used in conjuction with Amazon Athena to query flat files in S3 buckets using SQL.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| glue\_crawler\_name | Name of the Glue crawler. | `string` | n/a | yes |
| glue\_database\_name | Name of the Glue catalog database. | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| s3\_target\_bucket\_name | S3 target bucket for Glue crawler. | `string` | n/a | yes |
| target\_path | Path to crawler target file(s). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| glue\_crawler\_name | The name of the Glue crawler. |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
