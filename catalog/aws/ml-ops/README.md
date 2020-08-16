---
parent: Infrastructure Catalog
title: AWS ML-Ops
nav_exclude: false
---
# AWS ML-Ops

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/aws/ml-ops?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/aws/ml-ops)

## Overview


Error: unknown flag: --sort## Usage

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
