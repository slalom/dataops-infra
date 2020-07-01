
# AWS ML-Ops

`/catalog/aws/ml-ops`

## Overview


This module automates MLOps tasks associated with training Machine Learning models.

The module leverages Step Functions and Lambda functions as needed. The state machine
executes hyperparameter tuning, training, and deployments as needed. Deployment options
supported are Sagemaker endpoints and/or batch inference.

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_credentials\_file | Path to the AWS credentials file, used to ensure that the correct credentials are used during upload of the ECR image. | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| job\_name | Name prefix given to SageMaker model and training/tuning jobs (18 characters or less). | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| batch\_transform\_instance\_count | Number of batch transformation instances. | `number` | `1` | no |
| batch\_transform\_instance\_type | Instance type for batch inference. | `string` | `"ml.m4.xlarge"` | no |
| built\_in\_model\_image | Tuning ranges for hyperparameters.<br>Specifying this means that 'bring-your-own' model is not required and the ECR image not created. | `string` | `null` | no |
| byo\_model\_image\_name | Image and repo name for bring your own model. | `string` | `"byo-xgboost"` | no |
| byo\_model\_image\_source\_path | Local source path for bring your own model docker image. | `string` | `"source/containers/ml-ops-byo-xgboost"` | no |
| byo\_model\_image\_tag | Tag for bring your own model image. | `string` | `"latest"` | no |
| endpoint\_instance\_count | Number of initial endpoint instances. | `number` | `1` | no |
| endpoint\_instance\_type | Instance type for inference endpoint. | `string` | `"ml.m4.xlarge"` | no |
| endpoint\_name | SageMaker inference endpoint to be created/updated. Endpoint will be created if<br>it does not already exist. | `string` | `"training-endpoint"` | no |
| endpoint\_or\_batch\_transform | Choose whether to create/update an inference API endpoint or do batch inference on test data. | `string` | `"Batch Transform"` | no |
| feature\_store\_override | Optionally, you can override the default feature store bucket with a bucket that already exists. | `string` | `null` | no |
| glue\_job\_name | Name of the Glue data transformation job name. | `string` | `"data-transformation"` | no |
| glue\_job\_spark\_flag | (Default=True). True to use the default (Spark) Glue job type. False to use Python Shell. | `string` | `false` | no |
| inference\_comparison\_operator | Comparison operator for deploying the trained SageMaker model.<br>Used in combination with `inference_metric_threshold`.<br>Examples: 'NumericGreaterThan', 'NumericLessThan', etc. | `string` | `"NumericGreaterThan"` | no |
| inference\_metric\_threshold | Threshold for deploying the trained SageMaker model.<br>Used in combination with `inference_comparison_operator`. | `number` | `0.7` | no |
| max\_number\_training\_jobs | Maximum number of total training jobs for hyperparameter tuning. | `number` | `3` | no |
| max\_parallel\_training\_jobs | Maximimum number of training jobs running in parallel for hyperparameter tuning. | `number` | `1` | no |
| parameter\_ranges | Tuning ranges for hyperparameters.<br>Expects a map of one or both "ContinuousParameterRanges" and "IntegerParameterRanges".<br>Each item in the map should point to a list of object with the following keys:<br> - Name        - name of the variable to be tuned<br> - MinValue    - min value of the range<br> - MaxValue    - max value of the range<br> - ScalingType - 'Auto', 'Linear', 'Logarithmic', or 'ReverseLogarithmic' | <pre>map(list(object({<br>    Name        = string<br>    MinValue    = string<br>    MaxValue    = string<br>    ScalingType = string<br>  })))</pre> | <pre>{<br>  "ContinuousParameterRanges": [<br>    {<br>      "MaxValue": "10",<br>      "MinValue": "0",<br>      "Name": "gamma",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "20",<br>      "MinValue": "1",<br>      "Name": "min_child_weight",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "0.5",<br>      "MinValue": "0.1",<br>      "Name": "subsample",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "1",<br>      "MinValue": "0",<br>      "Name": "max_delta_step",<br>      "ScalingType": "Auto"<br>    },<br>    {<br>      "MaxValue": "10",<br>      "MinValue": "1",<br>      "Name": "scale_pos_weight",<br>      "ScalingType": "Auto"<br>    }<br>  ],<br>  "IntegerParameterRanges": [<br>    {<br>      "MaxValue": "10",<br>      "MinValue": "1",<br>      "Name": "max_depth",<br>      "ScalingType": "Auto"<br>    }<br>  ]<br>}</pre> | no |
| score\_local\_path | Local path for scoring data. Set to null for endpoint inference | `string` | `"source/data/score.csv"` | no |
| script\_path | Local path for Glue Python script. | `string` | `"source/scripts/transform.py"` | no |
| static\_hyperparameters | Map of hyperparameter names to static values, which should not be altered during hyperparameter tuning.<br>E.g. `{ "kfold_splits" = "5" }` | `map` | <pre>{<br>  "kfold_splits": "5"<br>}</pre> | no |
| train\_local\_path | Local path for training data. | `string` | `"source/data/train.csv"` | no |
| training\_job\_instance\_count | Number of instances for training jobs. | `number` | `1` | no |
| training\_job\_instance\_type | Instance type for training jobs. | `string` | `"ml.m4.xlarge"` | no |
| training\_job\_storage\_in\_gb | Instance volume size in GB for training jobs. | `number` | `30` | no |
| tuning\_metric | Hyperparameter tuning metric, e.g. 'error', 'auc', 'f1', 'accuracy'. | `string` | `"accuracy"` | no |
| tuning\_objective | Hyperparameter tuning objective ('Minimize' or 'Maximize'). | `string` | `"Maximize"` | no |
| whl\_path | Local path for Glue Python .whl file. | `string` | `"source/scripts/python/pandasmodule-0.1-py3-none-any.whl"` | no |

## Outputs

| Name | Description |
|------|-------------|
| summary | Summary of resources created by this module. |
## Usage

### General Usage Instructions

#### Prereqs:

1. Create glue jobs (see sample code in `transform.py`).

#### Terraform Config:

1. If additional python dependencies are needed, list these in [TK] config variable. These will be packaged into python wheels (`.whl` files) and uploaded to S3 automatically.
2. Configure terraform variable `script_path` with location of Glue transform code.

#### Terraform Deploy:

1. Run `terraform apply` which will create all resources and upload files to the correct bucket (enter 'yes' when prompted).

#### Execute State Machine:

1. Execute the state machine by landing first your training data and then your scoring (prediction) data into the feature store S3 bucket.

### Bring Your Own Model

_BYOM (Bring your own Model) allows you to build a custom docker image which will be used during state machine execution, in place of the generic training image._

For BYOM, perform all of the above and also the steps below.

#### Additional Configuration

Create a local folder in the code repository which contains at least the following files:

    * `Dockerfile`
    * `.Dockerignore`
    * `build_and_push.sh`
    * subfolder containing the following files:
      * Custom python:
        * `train` (with no file extension)
        * `predictor.py`
      * Generic / boilerplate (copy from standard sample):
        * `serve` (with no file extension)
        * `wsgi.py` (wrapper for gunicorn to find your app)
        * `nginx.conf`

## File Stores Used by MLOps Module

#### File Stores (S3 Buckets):

1. Input Buckets:
   1. Feature Store - Input training and scoring data.
2. Managed Buckets:
   1. Source Repository - Location where Glue python scripts are stored.
   2. Extract Store - Training data (model inputs) stored to be consumed by the training model. Default output location for the Glue transformation job(s).
   3. Model Store - Landing zone for pickled models as they are created and tuned by SageMaker training jobs.
   4. Metadata Store - For logging SageMaker metadata information about the tuning and training jobs.
   5. Output Store - Output from batch transformations (csv). Ignored when running endpoint inference.


---------------------

## Source Files

_Source code for this module is available using the links below._

* [ecr-image.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/ml-ops/ecr-image.tf)
* [glue-crawler.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/ml-ops/glue-crawler.tf)
* [glue-job.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/ml-ops/glue-job.tf)
* [lambda.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/ml-ops/lambda.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/ml-ops/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/ml-ops/outputs.tf)
* [s3.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/ml-ops/s3.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/ml-ops/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
