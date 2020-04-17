
# AWS Dynamodb

`/components/aws/dynamodb`

## Overview


DynamoDB is AWS's key-value and document NoSQL database. Data is stored in DynamoDB Tables.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| billing\_mode | How read and write throughput is charged (PROVISIONED or PAY\_PER\_REQUEST). | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| primary\_key | The attribute to use as the partition key. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dynamodb\_table\_arn | The ARN of the DynamoDB table. |
| dynamodb\_table\_name | The name of the DynamoDB table. |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
