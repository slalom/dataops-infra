
# AWS Ml-Ops-On-AWS

`/catalog/aws/ml-ops-on-aws`

## Overview


This module automates MLOps tasks associated with training Machine Learning models.

The module leverages Step Functions and Lambda functions as needed. The state machine
executes hyperparameter tuning, training, and deployments as needed. Deployment options
supported are Sagemaker endpoints and/or batch inference.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| feature\_store\_override | Optionally, you can override the default feature store bucket with a bucket that already exists. | `string` | n/a | yes |
| model\_name | Name given to SageMaker model and training/tuning jobs (18 characters or less). | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| training\_image\_override | SageMaker model container image URI from ECR repo. | `string` | n/a | yes |
| batch\_transform\_instance\_count | Number of batch transformation instances. | `number` | `1` | no |
| batch\_transform\_instance\_type | Instance type for batch inference. | `string` | `"ml.m4.xlarge"` | no |
| byo\_model\_repo\_name | Repo name for bring your own model. | `string` | `"byo-xgboost"` | no |
| byo\_model\_source\_image\_path | Local source path for bring your own model docker image. | `string` | `"source/containers/ml-ops-byo-xgboost"` | no |
| byo\_model\_tag | Tag for bring your own model image. | `string` | `"latest"` | no |
| endpoint\_instance\_count | Number of initial endpoint instances. | `number` | `1` | no |
| endpoint\_instance\_type | Instance type for inference endpoint. | `string` | `"ml.m4.xlarge"` | no |
| endpoint\_name | SageMaker inference endpoint to be created/updated. Endpoint will be created if<br>it does not already exist. | `string` | `"training-endpoint"` | no |
| endpoint\_or\_batch\_transform | Choose whether to create/update an inference API endpoint or do batch inference on test data. | `string` | `"Batch Transform"` | no |
| glue\_job\_name | Name of the Glue data transformation job name. | `string` | `"data-transformation"` | no |
| glue\_job\_type | Type of Glue job (Spark or Python Shell). | `string` | `"pythonshell"` | no |
| inference\_comparison\_operator | Comparison operator for deploying the trained SageMaker model.<br>Used in combination with `inference_metric_threshold`.<br>Examples: 'NumericGreaterThan', 'NumericLessThan', etc. | `string` | `"NumericGreaterThan"` | no |
| inference\_metric\_threshold | Threshold for deploying the trained SageMaker model.<br>Used in combination with `inference_comparison_operator`. | `number` | `0.7` | no |
| max\_number\_training\_jobs | Maximum number of total training jobs for hyperparameter tuning. | `number` | `3` | no |
| max\_parallel\_training\_jobs | Maximimum number of training jobs running in parallel for hyperparameter tuning. | `number` | `1` | no |
| parameter\_ranges | Tuning ranges for hyperparameters.<br>Expects a map of one or both "ContinuousParameterRanges" and "IntegerParameterRanges".<br>Each item in the map should point to a list of object with the following keys:  - Name        - name of the variable to be tuned  - MinValue    - min value of the range  - MaxValue    - max value of the range  - ScalingType - 'Auto', 'Linear', 'Logarithmic', or 'ReverseLogarithmic' | <pre>map(list(object({<br>    Name        = string<br>    MinValue    = string<br>    MaxValue    = string<br>    ScalingType = string<br>  })))</pre> | <pre>{<br>  "ContinuousParameterRanges": [<br>    {<br>      "MaxValue": "10",<br>      "MinValue": "0",<br>      "Name": "gamma",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "20",<br>      "MinValue": "1",<br>      "Name": "min_child_weight",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "0.5",<br>      "MinValue": "0.1",<br>      "Name": "subsample",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "1",<br>      "MinValue": "0",<br>      "Name": "max_delta_step",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "10",<br>      "MinValue": "1",<br>      "Name": "scale_pos_weight",<br>      "ScalingType": "Auto"<br>    }<br>  ],<br>  "IntegerParameterRanges": [<br>    {<br>      "MaxValue": "10",<br>      "MinValue": "1",<br>      "Name": "max_depth",<br>      "ScalingType": "Auto"<br>    }<br>  ]<br>}</pre> | no |
| score\_local\_path | Local path for scoring data. | `string` | `"source/data/score.csv"` | no |
| script\_path | Local path for Glue Python script. | `string` | `"source/scripts/transform.py"` | no |
| static\_hyperparameters | Map of hyperparameter names to static values, which should not be altered during hyperparameter tuning.<br>E.g. `{ "kfold_splits" = "5" }` | `map` | <pre>{<br>  "kfold_splits": "5"<br>}</pre> | no |
| train\_local\_path | Local path for training data. | `string` | `"source/data/train.csv"` | no |
| training\_job\_instance\_count | Number of instances for training jobs. | `number` | `1` | no |
| training\_job\_instance\_type | Instance type for training jobs. | `string` | `"ml.m4.xlarge"` | no |
| training\_job\_volume\_size\_gb | Instance volume size in GB for training jobs. | `number` | `30` | no |
| tuning\_metric | Hyperparameter tuning metric, e.g. 'error', 'auc', 'f1', 'accuracy'. | `string` | `"accuracy"` | no |
| tuning\_objective | Hyperparameter tuning objective ('Minimize' or 'Maximize'). | `string` | `"Maximize"` | no |
| whl\_path | Local path for Glue Python .whl file. | `string` | `"source/scripts/python/pandasmodule-0.1-py3-none-any.whl"` | no |

## Outputs

| Name | Description |
|------|-------------|
| summary | Summary of resources created by this module. |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
