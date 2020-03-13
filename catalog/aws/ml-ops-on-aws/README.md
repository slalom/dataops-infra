
# AWS Ml-Ops-On-AWS

`/catalog/aws/ml-ops-on-aws`

## Overview


This module automates MLOps tasks associated with building and maintaining Machine Learning models.
The module leverages Step Functions, Lambda functions, and ECS Tasks as needed to accomplish ML
lifecycle tasks and processing.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | n/a | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | n/a | `string` | n/a | yes |
| s3\_bucket\_name | n/a | `string` | n/a | yes |
| create\_endpoint\_error\_threshold | n/a | `number` | `0.2` | no |
| data\_folder | n/a | `string` | `"source/data"` | no |
| data\_s3\_path | n/a | `string` | `"data"` | no |
| endpoint\_name | n/a | `string` | `"xgboost-endpoint"` | no |
| job\_name | n/a | `string` | `"xgboost-job"` | no |
| max\_number\_training\_jobs | n/a | `number` | `2` | no |
| max\_parallel\_training\_jobs | n/a | `number` | `2` | no |
| parameter\_ranges | n/a | `map` | <pre>{<br>  "ContinuousParameterRanges": [<br>    {<br>      "MaxValue": "0.5",<br>      "MinValue": "0.1",<br>      "Name": "eta",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "100",<br>      "MinValue": "5",<br>      "Name": "min_child_weight",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "0.5",<br>      "MinValue": "0.1",<br>      "Name": "subsample",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "5",<br>      "MinValue": "0",<br>      "Name": "gamma",<br>      "ScalingType": "Auto"<br>    }<br>  ],<br>  "IntegerParameterRanges": [<br>    {<br>      "MaxValue": "10",<br>      "MinValue": "0",<br>      "Name": "max_depth",<br>      "ScalingType": "Auto"<br>    }<br>  ]<br>}</pre> | no |
| resource\_tags | n/a | `map` | `{}` | no |
| training\_image | n/a | `string` | `"811284229777.dkr.ecr.us-east-1.amazonaws.com/xgboost:1"` | no |
| tuning\_metric | n/a | `string` | `"validation:error"` | no |
| tuning\_objective | n/a | `string` | `"Minimize"` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam\_role\_arn | n/a |
| summary | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
