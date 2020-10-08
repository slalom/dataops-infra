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

- local

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

### glue\_transform\_script

Description: Local path for Glue Python script.
For example: "./source/scripts/transform.py"

Type: `string`

### job\_name

Description: Name prefix given to SageMaker model and training/tuning jobs (18 characters or less).

Type: `string`

### parameter\_ranges

Description: Tuning ranges for hyperparameters.
Expects a map of one or all "ContinuousParameterRanges", "IntegerParameterRanges", and "CategoricalParameterRanges".
Each item in the map should point to a list of object with the following keys:
 - Name        - name of the variable to be tuned
 - MinValue    - min value of the range
 - MaxValue    - max value of the range
 - ScalingType - 'Auto', 'Linear', 'Logarithmic', or 'ReverseLogarithmic'
 - Values      - a list of strings that apply to the categorical paramters

Type: `any`

### byo\_model\_repo\_name

Description: Name for your BYO model image repository.

Type: `string`

### aws\_credentials\_file

Description: Path to the AWS credentials file, used to ensure that the correct credentials are used during upload of the ECR image.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### glue\_dependency\_package

Description: Local path for Glue Python .whl file.

Type: `string`

Default: `"source/scripts/python/pandasmodule-0.1-py3-none-any.whl"`

### train\_local\_path

Description: Local path for training data.

Type: `string`

Default: `"source/data/train/train.csv"`

### score\_local\_path

Description: Local path for scoring data. Set to null for endpoint inference

Type: `string`

Default: `"source/data/score/score.csv"`

### ml\_bucket\_override

Description: Optionally, you can override the default ML bucket with a bucket that already exists.

Type: `string`

Default: `null`

### train\_key

Description: URL path postfix for training data. Provide a folder only if an image recognition problem, a csv file if a classification problem.

Type: `string`

Default: `"input_data/train/train.csv"`

### test\_key

Description: URL path postfix for testing data. Provide a folder only if an image recognition problem, a csv file if a classification problem.

Type: `string`

Default: `"input_data/test/test.csv"`

### validate\_key

Description: URL path postfix for validation data. Provide a folder only if an image recognition problem, a csv file if a classification problem.

Type: `string`

Default: `"input_data/validate/validate.csv"`

### input\_data\_content\_type

Description: Define the content type for the HPO job. If it is regular classification problem, content type is 'csv'; if image recognition, content type is
'application/x-recordio'

Type: `string`

Default: `"csv"`

### endpoint\_name

Description: SageMaker inference endpoint to be created/updated. Endpoint will be created if
it does not already exist.

Type: `string`

Default: `"training-endpoint"`

### endpoint\_or\_batch\_transform

Description: Choose whether to create/update an inference API endpoint or do batch inference on test data.

Type: `string`

Default: `"Batch Transform"`

### endpoint\_instance\_count

Description: Number of initial endpoint instances.

Type: `number`

Default: `1`

### endpoint\_instance\_type

Description: Instance type for inference endpoint.

Type: `string`

Default: `"ml.m4.xlarge"`

### batch\_transform\_instance\_count

Description: Number of batch transformation instances.

Type: `number`

Default: `1`

### batch\_transform\_instance\_type

Description: Instance type for batch inference.

Type: `string`

Default: `"ml.m4.xlarge"`

### static\_hyperparameters

Description: Map of hyperparameter names to static values, which should not be altered during hyperparameter tuning.
E.g. `{ "kfold_splits" = "5" }`

Type: `map`

Default: `{}`

### tuning\_strategy

Description: Hyperparameter tuning strategy, can be Bayesian or Random.

Type: `string`

Default: `"Bayesian"`

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

Description: threshold for deploying the trained SageMaker model.
Used in combination with `inference_comparison_operator`.

Type: `number`

Default: `0.7`

### built\_in\_model\_image

Description: One of the ECR image URIs from Amazon-stock SageMaker image definitions.
If specified, 'bring-your-own' model support is not required and the ECR image will not
be created.

Type: `string`

Default: `null`

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

### byo\_model\_image\_name

Description: Image and repo name for bring your own model.

Type: `string`

Default: `"byo-custom"`

### byo\_model\_image\_tag

Description: Tag for bring your own model image.

Type: `string`

Default: `"latest"`

### byo\_model\_source\_image\_path

Description: Local source path for bring your own model docker image.

Type: `string`

Default: `"source/containers/ml-ops-byo-custom"`

### byo\_model\_ecr\_tag\_name

Description: Tag name for the BYO ecr image.

Type: `string`

Default: `"latest"`

### glue\_job\_name

Description: Name of the Glue data transformation job name.

Type: `string`

Default: `"data-transformation"`

### glue\_job\_spark\_flag

Description: (Default=True). True to use the default (Spark) Glue job type. False to use Python Shell.

Type: `bool`

Default: `false`

### alarm\_name

Description: Name of the cloudwatch alarm

Type: `string`

Default: `"Model is Overfitting and Retraining Alarm"`

### alarm\_comparison\_operator

Description:   The arithmetic operation to use when comparing the specified alarm\_statistic and alarm\_threshold. The specified alarm\_statistic
  value is used as the first operand.Possible values include StringEquals, IsBoolean, StringLessThan, IsNumeric,
  BooleanEquals,
  StringLessThanEqualsPath, NumericLessThan, NumericGreaterThan,
  NumericLessThanPath, StringMatches, TimestampLessThanEqualsPath, NumericEquals,
  TimestampGreaterThan, StringGreaterThanEqualsPath, TimestampGreaterThanEqualsPath,
  TimestampLessThanEquals, NumericLessThanEqualsPath, TimestampEquals, BooleanEqualsPath,
  IsTimestamp, StringLessThanEquals, NumericLessThanEquals, StringLessThanPath,
  TimestampGreaterThanPath, StringGreaterThan, StringGreaterThanPath, IsString, StringEqualsPath,
  TimestampEqualsPath, TimestampLessThan, StringGreaterThanEquals, NumericGreaterThanPath,
  NumericGreaterThanEquals, NumericEqualsPath, TimestampLessThanPath,
  IsNull, IsPresent, TimestampGreaterThanEquals, NumericGreaterThanEqualsPath

Type: `string`

Default: `"NumericLessThan"`

### alarm\_evaluation\_period

Description:   The number of periods over which data is compared to the specified alarm\_threshold. If you are setting an alarm that
  requires that a number of consecutive data points be breaching to trigger the alarm, this value specifies that number.
  If you are setting an "M out of N" alarm, this value is the N.An alarm's total current evaluation period can be no longer
  than one day, so this number multiplied by Period cannot be more than 86,400 seconds.This parameter works in combination
  with alarm\_datapoints\_to\_evaluate for specifying how frequently the model performance will be monitored.

Type: `number`

Default: `10`

### alarm\_datapoints\_to\_evaluate

Description:   The number of data points that must be breaching to trigger the alarm. This is used only if you are setting an "M out of N"
  alarm. In that case, this value is the M.This parameter works in combination with alarm\_evaluation\_period for specifying how
  frequently the model performance will be monitored.

Type: `number`

Default: `10`

### alarm\_metric\_name

Description:   The name for the metric associated with the alarm. For each PutMetricAlarm operation, you must specify either MetricName or
  a Metrics array.If you are creating an alarm based on a math expression, you cannot specify this parameter, or any of the
  Dimensions , Period , Namespace , alarm\_statistic ,or Extendedalarm\_statistic parameters. Instead, you specify all this information in
  the Metrics array. Values include Training Accuray, Training Loss, Validation Accuracy, and Validation Loss.

Type: `string`

Default: `"Training Accuracy"`

### alarm\_metric\_evaluation\_period

Description: The granularity, in seconds, of the returned data points

Type: `number`

Default: `30`

### alarm\_statistic

Description: The alarm\_statistic to return. It can include any CloudWatch stats or extended stats

Type: `string`

Default: `"Maximum"`

### alarm\_statistic\_unit\_name

Description:   The unit of measure for the alarm\_statistic.You can also specify a unit when you create a custom metric. Units help provide conceptual
  meaning to your data. Metric data points that specify a unit of measure, such as Percent, are aggregated separately.
  If you don't specify Unit , CloudWatch retrieves all unit types that have been published for the metric and attempts to evaluate the alarm.
  Usually metrics are published with only one unit, so the alarm will work as intended.
  However, if the metric is published with multiple types of units and you don't specify a unit, the alarm's behavior is not defined and will
  behave un-predictably. We recommend omitting Unit so that you don't inadvertently specify an incorrect unit that is not published for this
  metric. Doing so causes the alarm to be stuck in the INSUFFICIENT DATA state.

  Possible values:
  Seconds, Microseconds, Milliseconds, Bytes, Kilobytes, Megabits, Gigabits, Terabits, Percent, Count, Bytes/Second, Kilobytes/Second, Megabytes/Second,
  Gigabytes/Second, Terabytes/Second, Bits/Second, Kilobits/Second, Megabits/Second, Gigabits/Second, Terabits/Second, Count/Second, and None.

Type: `string`

Default: `"Percent"`

### alarm\_threshold

Description: The baseline alarm\_threshold value that cloudwatch will compare against

Type: `number`

Default: `90`

### alarm\_actions\_enabled

Description: Indicates whether actions should be executed during any changes to the alarm state.

Type: `bool`

Default: `true`

### alarm\_description

Description: The description for the alarm.

Type: `string`

Default: `"Model is overfitting. Model retraining will be activated."`

### retrain\_on\_alarm

Description: Whether or not to retrain the model if detected overfitting.

Type: `bool`

Default: `false`

### data\_drift\_monitor\_name

Description: The name for the scheduled data drift monitoring job

Type: `string`

Default: `"data-drift-monitor-schedule"`

### data\_drift\_monitoring\_frequency

Description: The data\_drift\_monitoring\_frequency at which data drift monitoring is performed. Values include: hourly, daily, and daily\_every\_x\_hours (hour\_interval, starting\_hour)

Type: `string`

Default: `"daily"`

### data\_drift\_ml\_problem\_type

Description: The type of machine learning problem, including Classification, Image Recognition, and Regression

Type: `string`

Default: `"Classification"`

### data\_drift\_sampling\_percent

Description: The percentage used to sample the input data to perform a data drift detection

Type: `number`

Default: `50`

### data\_drift\_job\_timeout\_in\_sec

Description: Timeout in seconds. After this amount of time, Amazon SageMaker terminates the job regardless of its current status.

Type: `number`

Default: `3600`

### enable\_predictive\_db

Description: Enable loading prediction outputs from S3 to the selected database.

Type: `bool`

Default: `false`

### predictive\_db\_name

Description: The name for the database in PostgreSQL

Type: `string`

Default: `"model_outputs"`

### predictive\_db\_admin\_user

Description: Define admin user name for PostgreSQL.

Type: `string`

Default: `"pgadmin"`

### predictive\_db\_admin\_password

Description: Define admin user password for PostgreSQL.

Type: `string`

Default: `"Db1234asdf"`

### predictive\_db\_storage\_size\_in\_gb

Description: The allocated storage value is denoted in GB

Type: `string`

Default: `"10"`

### predictive\_db\_instance\_class

Description: Enter the desired node type. The default and cheapest option is 'db.t3.micro' @ ~$0.018/hr, or ~$13/mo (https://aws.amazon.com/rds/mysql/pricing/ )

Type: `string`

Default: `"db.t3.micro"`

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
2. Configure terraform variable `glue_transform_script` with location of Glue transform code.

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

* [ecr-image.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/ecr-image.tf)
* [glue-crawler.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/glue-crawler.tf)
* [glue-job.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/glue-job.tf)
* [lambda.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/lambda.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/outputs.tf)
* [s3.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/s3.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/ml-ops/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
