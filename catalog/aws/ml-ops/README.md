---
parent: Infrastructure Catalog
title: AWS ML-Ops
nav_exclude: false
---
# AWS ML-Ops

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/aws/ml-ops?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/aws/ml-ops)

## Overview


This module automates MLOps tasks associated with training Machine Learning models.

The module leverages Step Functions and Lambda functions as needed. The state machine
executes hyperparameter tuning, training, and deployments as needed. Deployment options
supported are Sagemaker endpoints and/or batch inference.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- null

- random

- aws

## Required Inputs

The following input variables are required:

### name\_prefix

Description: Standard `name_prefix` module input.

Type: `string`

### environment

Description: Standard `environment` module input.

Type:

```hcl
object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
```

### resource\_tags

Description: Standard `resource_tags` module input.

Type: `map(string)`

### job\_name

Description: Name prefix given to SageMaker model and training/tuning jobs (18 characters or less).

Type: `string`

### aws\_credentials\_file

Description: Path to the AWS credentials file, used to ensure that the correct credentials are used during upload of the ECR image.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### feature\_store\_override

Description: Optionally, you can override the default feature store bucket with a bucket that already exists.

Type: `string`

Default: `null`

### script\_path

Description: Local path for Glue Python script.

Type: `string`

Default: `"source/scripts/transform.py"`

### whl\_path

Description: Local path for Glue Python .whl file.

Type: `string`

Default: `"source/scripts/python/pandasmodule-0.1-py3-none-any.whl"`

### train\_local\_path

Description: Local path for training data.

Type: `string`

Default: `"source/data/train.csv"`

### score\_local\_path

Description: Local path for scoring data. Set to null for endpoint inference

Type: `string`

Default: `"source/data/score.csv"`

### endpoint\_name

Description: SageMaker inference endpoint to be created/updated. Endpoint will be created if
it does not already exist.

Type: `string`

Default: `"training-endpoint"`

### tuning\_objective

Description: Hyperparameter tuning objective ('Minimize' or 'Maximize').

Type: `string`

Default: `"Maximize"`

### tuning\_metric

Description: Hyperparameter tuning metric, e.g. 'error', 'auc', 'f1', 'accuracy'.

Type: `string`

Default: `"accuracy"`

### inference\_comparison\_operator

Description: Comparison operator for deploying the trained SageMaker model.
Used in combination with `inference_metric_threshold`.
Examples: 'NumericGreaterThan', 'NumericLessThan', etc.

Type: `string`

Default: `"NumericGreaterThan"`

### inference\_metric\_threshold

Description: Threshold for deploying the trained SageMaker model.
Used in combination with `inference_comparison_operator`.

Type: `number`

Default: `0.7`

### endpoint\_or\_batch\_transform

Description: Choose whether to create/update an inference API endpoint or do batch inference on test data.

Type: `string`

Default: `"Batch Transform"`

### batch\_transform\_instance\_count

Description: Number of batch transformation instances.

Type: `number`

Default: `1`

### batch\_transform\_instance\_type

Description: Instance type for batch inference.

Type: `string`

Default: `"ml.m4.xlarge"`

### endpoint\_instance\_count

Description: Number of initial endpoint instances.

Type: `number`

Default: `1`

### endpoint\_instance\_type

Description: Instance type for inference endpoint.

Type: `string`

Default: `"ml.m4.xlarge"`

### max\_number\_training\_jobs

Description: Maximum number of total training jobs for hyperparameter tuning.

Type: `number`

Default: `3`

### max\_parallel\_training\_jobs

Description: Maximimum number of training jobs running in parallel for hyperparameter tuning.

Type: `number`

Default: `1`

### training\_job\_instance\_count

Description: Number of instances for training jobs.

Type: `number`

Default: `1`

### training\_job\_instance\_type

Description: Instance type for training jobs.

Type: `string`

Default: `"ml.m4.xlarge"`

### training\_job\_storage\_in\_gb

Description: Instance volume size in GB for training jobs.

Type: `number`

Default: `30`

### static\_hyperparameters

Description: Map of hyperparameter names to static values, which should not be altered during hyperparameter tuning.
E.g. `{ "kfold_splits" = "5" }`

Type: `map`

Default:

```json
{
  "kfold_splits": "5"
}
```

### parameter\_ranges

Description: Tuning ranges for hyperparameters.
Expects a map of one or both "ContinuousParameterRanges" and "IntegerParameterRanges".
Each item in the map should point to a list of object with the following keys:
 - Name        - name of the variable to be tuned
 - MinValue    - min value of the range
 - MaxValue    - max value of the range
 - ScalingType - 'Auto', 'Linear', 'Logarithmic', or 'ReverseLogarithmic'

Type:

```hcl
map(list(object({
    Name        = string
    MinValue    = string
    MaxValue    = string
    ScalingType = string
  })))
```

Default:

```json
{
  "ContinuousParameterRanges": [
    {
      "MaxValue": "10",
      "MinValue": "0",
      "Name": "gamma",
      "ScalingType": "Auto"
    },
    {
      "MaxValue": "20",
      "MinValue": "1",
      "Name": "min_child_weight",
      "ScalingType": "Auto"
    },
    {
      "MaxValue": "0.5",
      "MinValue": "0.1",
      "Name": "subsample",
      "ScalingType": "Auto"
    },
    {
      "MaxValue": "1",
      "MinValue": "0",
      "Name": "max_delta_step",
      "ScalingType": "Auto"
    },
    {
      "MaxValue": "10",
      "MinValue": "1",
      "Name": "scale_pos_weight",
      "ScalingType": "Auto"
    }
  ],
  "IntegerParameterRanges": [
    {
      "MaxValue": "10",
      "MinValue": "1",
      "Name": "max_depth",
      "ScalingType": "Auto"
    }
  ]
}
```

### built\_in\_model\_image

Description: Tuning ranges for hyperparameters.
Specifying this means that 'bring-your-own' model is not required and the ECR image not created.

Type: `string`

Default: `null`

### byo\_model\_image\_name

Description: Image and repo name for bring your own model.

Type: `string`

Default: `"byo-xgboost"`

### byo\_model\_image\_source\_path

Description: Local source path for bring your own model docker image.

Type: `string`

Default: `"source/containers/ml-ops-byo-xgboost"`

### byo\_model\_image\_tag

Description: Tag for bring your own model image.

Type: `string`

Default: `"latest"`

### glue\_job\_name

Description: Name of the Glue data transformation job name.

Type: `string`

Default: `"data-transformation"`

### glue\_job\_spark\_flag

Description: (Default=True). True to use the default (Spark) Glue job type. False to use Python Shell.

Type: `string`

Default: `false`

## Outputs

The following outputs are exported:

### summary

Description: Summary of resources created by this module.
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

* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/outputs.tf)
* [lambda.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/lambda.tf)
* [s3.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/s3.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/main.tf)
* [ecr-image.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/ecr-image.tf)
* [glue-crawler.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/glue-crawler.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/variables.tf)
* [glue-job.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/glue-job.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
