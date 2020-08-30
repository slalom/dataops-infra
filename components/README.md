---
title: Infrastructure Components
has_children: true
nav_order: 3
nav_exclude: false
---
# DataOps Infrastructure Components

These components define the technical building blocks which enable advanced, ready-to-deploy data solutions in the [Infrastructure Catalog](../catalog/README.md).

## Contents

1. [AWS Components](#aws-components)
    - [AWS Redshift](#aws-redshift)
    - [AWS ECR-Image](#aws-ecr-image)
    - [AWS Glue-Crawler](#aws-glue-crawler)
    - [AWS VPC](#aws-vpc)
    - [AWS Step-Functions](#aws-step-functions)
    - [AWS ECS-Task](#aws-ecs-task)
    - [AWS ECR](#aws-ecr)
    - [AWS Lambda-Python](#aws-lambda-python)
    - [AWS Glue-Job](#aws-glue-job)
    - [AWS ECS-Cluster](#aws-ecs-cluster)
    - [AWS EC2](#aws-ec2)
    - [AWS RDS](#aws-rds)
    - [AWS Secrets-Manager](#aws-secrets-manager)

2. Azure Components
    * _(Coming soon)_
2. GCP Components
    * _(Coming soon)_

## AWS Components

### AWS Redshift

#### Overview

This is the underlying technical component which supports the Redshift catalog module.

NOTE: Requires AWS policy 'AmazonRedshiftFullAccess' on the terraform account

#### Documentation

- [AWS Redshift Readme](../components/aws/redshift/README.md)

-------------------

### AWS ECR-Image

#### Overview

ECR (Elastic Compute Repository) is the private-hosted AWS
equivalent of DockerHub. ECR allows you to securely publish
docker images which should not be accessible to external users.


#### Documentation

- [AWS ECR-Image Readme](../components/aws/ecr-image/README.md)

-------------------

### AWS Glue-Crawler

#### Overview

Glue is AWS's fully managed extract, transform, and load (ETL) service.
A Glue crawler is used to access a data store and create table definitions.
This can be used in conjuction with Amazon Athena to query flat files in S3 buckets using SQL.

#### Documentation

- [AWS Glue-Crawler Readme](../components/aws/glue-crawler/README.md)

-------------------

### AWS VPC

#### Overview

The VPC module creates a number of network services which support other key AWS functions.

Included automatically when creating this module:
* 1 VPC which contains the following:
    * 2 private subnets (for resources which **do not** need a public IP address)
    * 2 public subnets (for resources which do need a public IP address)
    * 1 NAT gateway (allows private subnet resources to reach the outside world)
    * 1 Intenet gateway (allows resources in public and private subnets to reach the internet)
    * route tables and routes to connect all of the above

#### Documentation

- [AWS VPC Readme](../components/aws/vpc/README.md)

-------------------

### AWS Step-Functions

#### Overview

AWS Step Functions is a service provided by Amazon Web Services that makes it easier to orchestrate multiple AWS services
to accomplish tasks. Step Functions allows you to create steps in a process where the output of one step becomes the input
for another step.


#### Documentation

- [AWS Step-Functions Readme](../components/aws/step-functions/README.md)

-------------------

### AWS ECS-Task

#### Overview

ECS, or EC2 Container Service, is able to run docker containers natively in AWS cloud. While the module can support classic EC2-based and Fargate,
features, this module generally prefers "ECS Fargete", which allows dynamic launching of docker containers with no always-on cost and no servers
to manage or pay for when tasks are not running.

Use in combination with the `ECS-Cluster` component.

#### Documentation

- [AWS ECS-Task Readme](../components/aws/ecs-task/README.md)

-------------------

### AWS ECR

#### Overview

ECR (Elastic Compute Repository) is the private-hosted AWS equivalent of DockerHub. ECR allows you to securely publish docker images which
should not be accessible to external users.


#### Documentation

- [AWS ECR Readme](../components/aws/ecr/README.md)

-------------------

### AWS Lambda-Python

#### Overview

AWS Lambda is a platform which enables serverless execution of arbitrary functions. This module specifically focuses on the
Python implementatin of Lambda functions. Given a path to a folder of one or more python fyles, this module takes care of
packaging the python code into a zip and uploading to a new Lambda Function in AWS. The module can also be configured with
S3-based triggers, to run the function automatically whenever a file is landed in a specific S3 path.


#### Documentation

- [AWS Lambda-Python Readme](../components/aws/lambda-python/README.md)

-------------------

### AWS Glue-Job

#### Overview

Glue is AWS's fully managed extract, transform, and load (ETL) service. A Glue job can be used job to run ETL Python scripts.

#### Documentation

- [AWS Glue-Job Readme](../components/aws/glue-job/README.md)

-------------------

### AWS ECS-Cluster

#### Overview

ECS, or EC2 Container Service, is able to run docker containers natively in AWS cloud. While the module can support classic EC2-based and Fargate,
features, this module generally prefers "ECS Fargete", which allows dynamic launching of docker containers with no always-on cost and no servers
to manage or pay for when tasks are not running.

Use in combination with the `ECS-Task` component.

#### Documentation

- [AWS ECS-Cluster Readme](../components/aws/ecs-cluster/README.md)

-------------------

### AWS EC2

#### Overview

EC2 is the virtual machine layer of the AWS platform. This module allows you to pass your own startup scripts, and it streamlines the creation and usage of
credentials (passwords and/or SSH keypairs) needed to connect to the instances.



#### Documentation

- [AWS EC2 Readme](../components/aws/ec2/README.md)

-------------------

### AWS RDS

#### Overview

Deploys an RDS-backed database. RDS currently supports the following database engines:
* Aurora
* MySQL
* PostgreSQL
* Oracle
* SQL Server

Each engine type has it's own required configuration. For already-configured database
configurations, see the catalog modules: `catalog/aws/mysql` and `catalog/aws/postgres`
which are built on top of this component module.

* NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

#### Documentation

- [AWS RDS Readme](../components/aws/rds/README.md)

-------------------

### AWS Secrets-Manager

#### Overview

This module takes as input a set of maps from variable names to secrets locations (in YAML or
JSON). The module uploads those secrets to AWS Secrets Manager and returns the same map pointing
to the IDs of new AWS Secrets manager locations. Those IDs (aka ARNs) can then safely be handed
on to other resources which required access to those secrets.

**Usage Notes:**

* Any secrets locations which are already pointing to AWS secrets will simply be passed back through to the output with no changes.
* For security reasons, this module does not accept inputs for secrets using the clear text of the secrets themselves. To properly use this module, first save the secrets to a YAML or JSON file which is excluded from source control.


#### Documentation

- [AWS Secrets-Manager Readme](../components/aws/secrets-manager/README.md)

-------------------



## Azure Components

_(Coming soon)_

## GCP Components

_(Coming soon)_

-------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs`. Please do not attempt to manually update
this file._

