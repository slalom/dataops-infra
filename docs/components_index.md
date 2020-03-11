
# DataOps Infrastructure Components

These components define the technical building blocks which enable advanced, ready-to-deploy data solutions in the [Infrastructure Catalog](catalog_index.md).

## Contents

1. [AWS Components](#aws-Components)
    - [AWS EC2](#AWS-EC2)
    - [AWS ECR](#AWS-ECR)
    - [AWS ECS-Cluster](#AWS-ECS-Cluster)
    - [AWS ECS-Task](#AWS-ECS-Task)
    - [AWS IAM](#AWS-IAM)
    - [AWS Lambda-Python](#AWS-Lambda-Python)
    - [AWS Redshift](#AWS-Redshift)
    - [AWS Secrets-Manager](#AWS-Secrets-Manager)
    - [AWS Step-Functions](#AWS-Step-Functions)
    - [AWS VPC](#AWS-VPC)

2. Azure Components
    * _(Coming soon)_
2. GCP Components
    * _(Coming soon)_

## AWS Components

### [AWS EC2](../components/aws/ec2/README.md)

```
source = git::https://github.com/slalom-ggp/dataops-infra//components/aws/ec2?ref=master
```



* See the [AWS EC2 Readme](../components/aws/ec2/README.md) for additional info
-------------------

### [AWS ECR](../components/aws/ecr/README.md)

```
source = git::https://github.com/slalom-ggp/dataops-infra//components/aws/ecr?ref=master
```



* See the [AWS ECR Readme](../components/aws/ecr/README.md) for additional info
-------------------

### [AWS ECS-Cluster](../components/aws/ecs-cluster/README.md)

```
source = git::https://github.com/slalom-ggp/dataops-infra//components/aws/ecs-cluster?ref=master
```



* See the [AWS ECS-Cluster Readme](../components/aws/ecs-cluster/README.md) for additional info
-------------------

### [AWS ECS-Task](../components/aws/ecs-task/README.md)

```
source = git::https://github.com/slalom-ggp/dataops-infra//components/aws/ecs-task?ref=master
```



* See the [AWS ECS-Task Readme](../components/aws/ecs-task/README.md) for additional info
-------------------

### [AWS IAM](../components/aws/iam/README.md)

```
source = git::https://github.com/slalom-ggp/dataops-infra//components/aws/iam?ref=master
```



* See the [AWS IAM Readme](../components/aws/iam/README.md) for additional info
-------------------

### [AWS Lambda-Python](../components/aws/lambda-python/README.md)

```
source = git::https://github.com/slalom-ggp/dataops-infra//components/aws/lambda-python?ref=master
```



* See the [AWS Lambda-Python Readme](../components/aws/lambda-python/README.md) for additional info
-------------------

### [AWS Redshift](../components/aws/redshift/README.md)

```
source = git::https://github.com/slalom-ggp/dataops-infra//components/aws/redshift?ref=master
```



* See the [AWS Redshift Readme](../components/aws/redshift/README.md) for additional info
-------------------

### [AWS Secrets-Manager](../components/aws/secrets-manager/README.md)

```
source = git::https://github.com/slalom-ggp/dataops-infra//components/aws/secrets-manager?ref=master
```

# AWS Secrets Manager

`components/aws/secrets-manager`

## Overview

This module takes as input a set of maps from variable names to secrets locations (in YAML or JSON). The module uploads those secrets to AWS Secrets Manager and returns the same map pointing to the IDs of new AWS Secrets manager locations. Those IDs (aka ARNs) can then safely be handed on to other resources which required access to those secrets.

**Usage Notes:**

* Any secrets locations which are already pointing to AWS secrets will simply be passed back through to the output with no changes.
* For security reasons, this module does not accept inputs for secrets using the clear text of the secrets themselves. To properly use this module, first save the secrets to a YAML or JSON file which is excluded from source control.

## Usage Example

**Sample inputs:**

```hcl
  secrets_file_map = {
    # These secret will be retrieved from the respective files and uploaded
    # to AWS Secrets Manager:
    MY_SAMPLE_1_username = "./.secrets/mysample1-creds.yml:username
    MY_SAMPLE_1_password = "./.secrets/mysample1-creds.yml:password
    MY_SAMPLE_2_username = "./.secrets/mysample2-creds.json:username
    MY_SAMPLE_2_password = "./.secrets/mysample2-creds.json:password

    # Because the paths starts with `arn://`, these secret are assumed to be
    # already in AWS Secrets Manager and will not be uploaded:
    SAMPLE_aws_access_key_id     = "arn:aws:secretsmanager:us-east-1::secret:aws_access_key_id-sqQDPG"
    SAMPLE_aws_secret_access_key = "arn:aws:secretsmanager:us-east-1::secret:aws_secret_access_key-adf13"
  }
```

**Outputs from sample:**

```hcl
{
    # Newly created AWS Secrets Manager secrets:
    MY_SAMPLE_1_username = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_1_username-adf13"
    MY_SAMPLE_1_password = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_1_password-adf13"
    MY_SAMPLE_2_username = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_2_username-adf13"
    MY_SAMPLE_2_password = "arn:aws:secretsmanager:us-east-1::secret:MY_SAMPLE_2_password-adf13"

    # Secrets IDs passed through with no change:
    SAMPLE_aws_access_key_id     = "arn:aws:secretsmanager:us-east-1::secret:aws_access_key_id-adf13"
    SAMPLE_aws_secret_access_key = "arn:aws:secretsmanager:us-east-1::secret:aws_secret_access_key-adf13"
}
```


* See the [AWS Secrets-Manager Readme](../components/aws/secrets-manager/README.md) for additional info
-------------------

### [AWS Step-Functions](../components/aws/step-functions/README.md)

```
source = git::https://github.com/slalom-ggp/dataops-infra//components/aws/step-functions?ref=master
```



* See the [AWS Step-Functions Readme](../components/aws/step-functions/README.md) for additional info
-------------------

### [AWS VPC](../components/aws/vpc/README.md)

```
source = git::https://github.com/slalom-ggp/dataops-infra//components/aws/vpc?ref=master
```



* See the [AWS VPC Readme](../components/aws/vpc/README.md) for additional info
-------------------



## Azure Components

_(Coming soon)_

## GCP Components

_(Coming soon)_

-------------------

_**NOTE:** This documentation was [auto-generated](build.py) using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._

