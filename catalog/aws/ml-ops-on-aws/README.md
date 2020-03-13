
# AWS Ml-Ops-On-AWS

`/catalog/aws/ml-ops-on-aws`

## Overview


This module automates MLOps tasks associated with building and maintaining Machine Learning models.
The module leverages Step Functions, Lambda functions, and ECS Tasks as needed to accomplish ML
lifecycle tasks and processing.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| s3\_bucket\_name | Extract S3 bucket name. | `string` | n/a | yes |
| container\_image | Container image for Shap dataset creation. | `string` | `"954496255132.dkr.ecr.us-east-1.amazonaws.com/shap-xgboost:latest"` | no |
| container\_num\_cores | Number of cores for ECS task. | `number` | `2` | no |
| container\_ram\_gb | GB RAM for ECS task. | `number` | `4` | no |
| create\_endpoint\_comparison\_operator | Comparison operator for endpoint creation metric threshold. | `string` | `"NumericLessThan"` | no |
| create\_endpoint\_metric\_threshold | Threshold for creating/updating SageMaker endpoint. | `number` | `0.2` | no |
| data\_folder | Local folder for training and validation data extracts. | `string` | `"source/data"` | no |
| data\_s3\_path | S3 path for training and validation data extracts. | `string` | `"data"` | no |
| endpoint\_name | SageMaker inference endpoint to be created/updated (depending on whether or not the endpoint already exists). | `string` | `"xgboost-endpoint"` | no |
| job\_name | SageMaker Hyperparameter Tuning job name. | `string` | `"xgboost-job"` | no |
| max\_number\_training\_jobs | Maximum number of total training jobs for hyperparameter tuning. | `number` | `2` | no |
| max\_parallel\_training\_jobs | Maximimum number of training jobs running in parallel for hyperparameter tuning. | `number` | `2` | no |
| parameter\_ranges | Tuning ranges for hyperparameters. | `map` | <pre>{<br>  "ContinuousParameterRanges": [<br>    {<br>      "MaxValue": "0.5",<br>      "MinValue": "0.1",<br>      "Name": "eta",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "100",<br>      "MinValue": "5",<br>      "Name": "min_child_weight",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "0.5",<br>      "MinValue": "0.1",<br>      "Name": "subsample",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "5",<br>      "MinValue": "0",<br>      "Name": "gamma",<br>      "ScalingType": "Auto"<br>    }<br>  ],<br>  "IntegerParameterRanges": [<br>    {<br>      "MaxValue": "10",<br>      "MinValue": "0",<br>      "Name": "max_depth",<br>      "ScalingType": "Auto"<br>    }<br>  ]<br>}</pre> | no |
| training\_image | SageMaker model container image. | `string` | `"811284229777.dkr.ecr.us-east-1.amazonaws.com/xgboost:1"` | no |
| tuning\_metric | Hyperparameter tuning metric e.g. error, auc, f1. | `string` | `"validation:error"` | no |
| tuning\_objective | Hyperparameter tuning objective (minimize or maximize). | `string` | `"Minimize"` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam\_role\_arn | n/a |
| summary | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
