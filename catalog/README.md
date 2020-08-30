---
parent: Infrastructure Catalog
title: .. Catalog
nav_exclude: false
---
# .. Catalog

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/catalog?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/catalog)

## Overview


## Requirements

No requirements.

## Providers

No provider.

## Required Inputs

No required input.

## Optional Inputs

No optional input.

## Outputs

No output.
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

## Usage

This module supports multiple taps per each target. To target multiple destinations, simply create
additional instances of the module.

### Tap configuration overview

The `taps` input variable expects a list of specifications for each tap. The specification for each
tap should include the following properties:

- `id` - The name or alias of the tap as registered in the [Singer Index](#singer-index), without the `tap-` prefix.
  - Note: in most cases, this is exactly what you'd expect: `mssql` for `tap-mssql`, etc. However,
    for forks or experimental releases, this might contain a suffix such as `mssql-test` for a test
    version of `tap-mssql` or `snowflake-singer` for the singer edition of `tap-snowflake`.
  - A future release will add a separate and optional flag for `owner` or `variant`, in place of the
    currently used alias/suffix convention. See the [Singer Index](#singer-index) section for more
    info.
- `name` - What you want to call the data source. For instance, if you have multiple SQL Servers, you may want to use a more memorable name such as `finance-system` or `gl-db`. This name should still align with tap naming conventions, which is to say it should be in _lower-case-with-dashes_ format.
- `settings` - A simple map of the tap settings' names to their values. These are specific to each tap and they are required for each tap to work.
  - Note: While singer does not distinguish between 'secrets' and 'settings', we should and do treat these two types of config separately. Be sure to put all sensitive config in the `secrets` collection, and not here in `settings`.
- `secrets` - Same as `config` except for sensitive values. When passing secrets, you specify the setting name in the same way but you _must_ either pass the value as a pointer to the file containing the secret (a config.json file, for instance) or else pass a AWS Secrets Manager ARN.
  - _If you pass a Secrets Manager ARN as the config value_, that secret pointer will be passed to the ECS container securely, and only the running container will have access to the secret.
  - _If you pass a pointer to a config file_, the module will automatically create a new AWS Secrets Manager secret, upload the secret to AWS Secrets Manager, and then the above process will continue by passing the Secrets Manager pointer _only_ to the running ECS container.

### Singer Index

There are actually two Singer Indexes currently available.

1. The first and primary index for this module today is the tapdance index stored [here](https://github.com/aaronsteers/tapdance/blob/master/docker/singer_index.yml).

2. This index will be eventually be replaced by a new dedicated [Singer DB](https://github.com/aaronsteers/singer-db), which is still a work-in-progress.

Note:

- Both of these sources support multiple versions (forks) of each tap, and both provide a "default"
  or "recommended" version for those new users who just want to get started quickly.
- The new [Singer DB](https://github.com/aaronsteers/singer-db) will implement a new "owner" or "variant"
  flag to replace the current "alias" technique used by the
  [tapdance index](https://github.com/aaronsteers/tapdance/blob/master/docker/singer_index.yml).


---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [ecr-image.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/ecr-image.tf)
* [glue-crawler.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/glue-crawler.tf)
* [glue-job.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/glue-job.tf)
* [lambda.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/lambda.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [s3.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/s3.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [cloudwatch.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/cloudwatch.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [s3-path-parsing.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/s3-path-parsing.tf)
* [s3-upload.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/s3-upload.tf)
* [step-functions.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/step-functions.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
