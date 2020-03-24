
# DataOps Infrastructure Components

These components define the technical building blocks which enable advanced, ready-to-deploy data solutions in the [Infrastructure Catalog](../catalog/README.md).

## Contents

1. [AWS Components](#aws-components)
    - [AWS EC2](#aws-ec2)
    - [AWS ECR](#aws-ecr)
    - [AWS ECS-Cluster](#aws-ecs-cluster)
    - [AWS ECS-Task](#aws-ecs-task)
    - [AWS Lambda-Python](#aws-lambda-python)
    - [AWS RDS](#aws-rds)
    - [AWS Redshift](#aws-redshift)
    - [AWS Secrets-Manager](#aws-secrets-manager)
    - [AWS Step-Functions](#aws-step-functions)
    - [AWS VPC](#aws-vpc)

2. Azure Components
    * _(Coming soon)_
2. GCP Components
    * _(Coming soon)_

## AWS Components

### [AWS EC2](../components/aws/ec2/README.md)

EC2 is the virtual machine layer of the AWS platform. This module allows you to pass your own startup scripts, and it streamlines the creation and usage of
credentials (passwords and/or SSH keypairs) needed to connect to the instances.



* Source: `git::https://github.com/slalom-ggp/dataops-infra//components/aws/ec2?ref=master`
* See the [AWS EC2 Readme](../components/aws/ec2/README.md) for input/output specs and additional info.

-------------------

### [AWS ECR](../components/aws/ecr/README.md)

ECR (Elastic Compute Repository) is the private-hosted AWS equivalent of DockerHub. ECR allows you to securely publish docker images which
should not be accessible to external users.


* Source: `git::https://github.com/slalom-ggp/dataops-infra//components/aws/ecr?ref=master`
* See the [AWS ECR Readme](../components/aws/ecr/README.md) for input/output specs and additional info.

-------------------

### [AWS ECS-Cluster](../components/aws/ecs-cluster/README.md)

ECS, or EC2 Container Service, is able to run docker containers natively in AWS cloud. While the module can support classic EC2-based and Fargate,
features, this module generally prefers "ECS Fargete", which allows dynamic launching of docker containers with no always-on cost and no servers
to manage or pay for when tasks are not running.

Use in combination with the `ECS-Task` component.

* Source: `git::https://github.com/slalom-ggp/dataops-infra//components/aws/ecs-cluster?ref=master`
* See the [AWS ECS-Cluster Readme](../components/aws/ecs-cluster/README.md) for input/output specs and additional info.

-------------------

### [AWS ECS-Task](../components/aws/ecs-task/README.md)

ECS, or EC2 Container Service, is able to run docker containers natively in AWS cloud. While the module can support classic EC2-based and Fargate,
features, this module generally prefers "ECS Fargete", which allows dynamic launching of docker containers with no always-on cost and no servers
to manage or pay for when tasks are not running.

Use in combination with the `ECS-Cluster` component.

* Source: `git::https://github.com/slalom-ggp/dataops-infra//components/aws/ecs-task?ref=master`
* See the [AWS ECS-Task Readme](../components/aws/ecs-task/README.md) for input/output specs and additional info.

-------------------

### [AWS Lambda-Python](../components/aws/lambda-python/README.md)

AWS Lambda is a platform which enables serverless execution of arbitrary functions. This module specifically focuses on the
Python implementatin of Lambda functions. Given a path to a folder of one or more python fyles, this module takes care of
packaging the python code into a zip and uploading to a new Lambda Function in AWS. The module can also be configured with
S3-based triggers, to run the function automatically whenever a file is landed in a specific S3 path.


* Source: `git::https://github.com/slalom-ggp/dataops-infra//components/aws/lambda-python?ref=master`
* See the [AWS Lambda-Python Readme](../components/aws/lambda-python/README.md) for input/output specs and additional info.

-------------------

### [AWS RDS](../components/aws/rds/README.md)

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

* Source: `git::https://github.com/slalom-ggp/dataops-infra//components/aws/rds?ref=master`
* See the [AWS RDS Readme](../components/aws/rds/README.md) for input/output specs and additional info.

-------------------

### [AWS Redshift](../components/aws/redshift/README.md)

This is the underlying technical component which supports the Redshift catalog module.

NOTE: Requires AWS policy 'AmazonRedshiftFullAccess' on the terraform account

* Source: `git::https://github.com/slalom-ggp/dataops-infra//components/aws/redshift?ref=master`
* See the [AWS Redshift Readme](../components/aws/redshift/README.md) for input/output specs and additional info.

-------------------

### [AWS Secrets-Manager](../components/aws/secrets-manager/README.md)

This module takes as input a set of maps from variable names to secrets locations (in YAML or
JSON). The module uploads those secrets to AWS Secrets Manager and returns the same map pointing
to the IDs of new AWS Secrets manager locations. Those IDs (aka ARNs) can then safely be handed
on to other resources which required access to those secrets.

**Usage Notes:**

* Any secrets locations which are already pointing to AWS secrets will simply be passed back through to the output with no changes.
* For security reasons, this module does not accept inputs for secrets using the clear text of the secrets themselves. To properly use this module, first save the secrets to a YAML or JSON file which is excluded from source control.


* Source: `git::https://github.com/slalom-ggp/dataops-infra//components/aws/secrets-manager?ref=master`
* See the [AWS Secrets-Manager Readme](../components/aws/secrets-manager/README.md) for input/output specs and additional info.

-------------------

### [AWS Step-Functions](../components/aws/step-functions/README.md)

AWS Step Functions is a service provided by Amazon Web Services that makes it easier to orchestrate multiple AWS services
to accomplish tasks. Step Functions allows you to create steps in a process where the output of one step becomes the input
for another step.


* Source: `git::https://github.com/slalom-ggp/dataops-infra//components/aws/step-functions?ref=master`
* See the [AWS Step-Functions Readme](../components/aws/step-functions/README.md) for input/output specs and additional info.

-------------------

### [AWS VPC](../components/aws/vpc/README.md)

The VPC module creates a number of network services which support other key AWS functions.

Included automatically when creating this module:
* 1 VPC which contains the following:
    * 2 private subnets (for resources which **do not** need a public IP address)
    * 2 public subnets (for resources which do need a public IP address)
    * 1 NAT gateway (allows private sugnet resources to reach the outside world)
    * 1 Intenet gateway (allows resources in public and private subnets to reach the internet)
    * route tables and routes to connect all of the above

* Source: `git::https://github.com/slalom-ggp/dataops-infra//components/aws/vpc?ref=master`
* See the [AWS VPC Readme](../components/aws/vpc/README.md) for input/output specs and additional info.

-------------------



## Azure Components

_(Coming soon)_

## GCP Components

_(Coming soon)_

-------------------

_**NOTE:** This documentation was [auto-generated](../docs/build.py) using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._

