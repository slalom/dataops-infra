
# DataOps Infrastructure Catalog

The Infrastructure Catalog contains ready-to-deploy terraform modules for a variety of production data project use cases and POCs. For information about the technical building blocks used in these modules, please see the catalog [components index](../components/README.md).

## Contents

1. [AWS Catalog](#aws-catalog)
    - [AWS Airflow](#aws-airflow)
    - [AWS Data-Lake](#aws-data-lake)
    - [AWS Data-Lake-Users](#aws-data-lake-users)
    - [AWS DBT](#aws-dbt)
    - [AWS Dev-Box](#aws-dev-box)
    - [AWS Environment](#aws-environment)
    - [AWS ML-Ops](#aws-ml-ops)
    - [AWS MySQL](#aws-mysql)
    - [AWS Postgres](#aws-postgres)
    - [AWS Redshift](#aws-redshift)
    - [AWS SFTP](#aws-sftp)
    - [AWS SFTP-Users](#aws-sftp-users)
    - [AWS Singer-Taps](#aws-singer-taps)
    - [AWS Tableau-Server](#aws-tableau-server)

2. Azure Catalog
    * _(Coming soon)_
2. GCP Catalog
    * _(Coming soon)_

## AWS Catalog

### AWS Airflow

#### Overview

Airflow is an open source platform to programmatically author, schedule and monitor workflows. More information here: [airflow.apache.org](https://airflow.apache.org/)


#### Documentation

- [AWS Airflow Readme](../catalog/aws/airflow/README.md)

-------------------

### AWS Data-Lake

#### Overview

This data lake implementation creates three buckets, one each for data, logging, and metadata. The data lake also supports lambda functions which can
trigger automatically when new content is added.

* Designed to be used in combination with the `aws/data-lake-users` module.
* To add SFTP protocol support, combine this module with the `aws/sftp` module.


#### Documentation

- [AWS Data-Lake Readme](../catalog/aws/data-lake/README.md)

-------------------

### AWS Data-Lake-Users

#### Overview

Automates the management of users and groups in an S3 data lake.

* Designed to be used in combination with the `aws/data-lake` module.


#### Documentation

- [AWS Data-Lake-Users Readme](../catalog/aws/data-lake-users/README.md)

-------------------

### AWS DBT

#### Overview

DBT (Data Built Tool) is a CI/CD and DevOps-friendly platform for automating data transformations. More info at [www.getdbt.com](https://www.getdbt.com).



#### Documentation

- [AWS DBT Readme](../catalog/aws/dbt/README.md)

-------------------

### AWS Dev-Box

#### Overview

The `dev-box` catalog module deploys an ECS-backed container which can be used to remotely test
or develop using the native cloud environment. Applicable use cases include:

* Debugging network firewall and routing rules
* Debugging components which can only be run from whitelisted IP ranges
* Offloading heavy processing from the developer's local laptop
* Mitigating network relability issues when working from WiFi or home networks


#### Documentation

- [AWS Dev-Box Readme](../catalog/aws/dev-box/README.md)

-------------------

### AWS Environment

#### Overview

The environment module sets up common infrastrcuture like VPCs and network subnets. The `envrionment` output
from this module is designed to be passed easily to downstream modules, streamlining the reuse of these core components.



#### Documentation

- [AWS Environment Readme](../catalog/aws/environment/README.md)

-------------------

### AWS ML-Ops

#### Overview

This module automates MLOps tasks associated with training Machine Learning models.

The module leverages Step Functions and Lambda functions as needed. The state machine
executes hyperparameter tuning, training, and deployments as needed. Deployment options
supported are Sagemaker endpoints and/or batch inference.

#### Documentation

- [AWS ML-Ops Readme](../catalog/aws/ml-ops/README.md)

-------------------

### AWS MySQL

#### Overview

Deploys a MySQL server running on RDS.

* NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

#### Documentation

- [AWS MySQL Readme](../catalog/aws/mysql/README.md)

-------------------

### AWS Postgres

#### Overview

Deploys a Postgres server running on RDS.

* NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

#### Documentation

- [AWS Postgres Readme](../catalog/aws/postgres/README.md)

-------------------

### AWS Redshift

#### Overview

Redshift is an AWS database platform which applies MPP (Massively-Parallel-Processing) principles to big data workloads in the cloud.


#### Documentation

- [AWS Redshift Readme](../catalog/aws/redshift/README.md)

-------------------

### AWS SFTP

#### Overview

Automates the management of the AWS Transfer Service, which
provides an SFTP interface on top of existing S3 storage resources.

* Designed to be used in combination with the `aws/data-lake` and `aws/sftp-users` modules.



#### Documentation

- [AWS SFTP Readme](../catalog/aws/sftp/README.md)

-------------------

### AWS SFTP-Users

#### Overview

Automates the management of SFTP user accounts on the AWS Transfer Service. AWS Transfer Service
provides an SFTP interface on top of existing S3 storage resources.

* Designed to be used in combination with the `aws/sftp` module.


#### Documentation

- [AWS SFTP-Users Readme](../catalog/aws/sftp-users/README.md)

-------------------

### AWS Singer-Taps

#### Overview

The Singer Taps platform is the open source stack which powers the [Stitcher](https://www.stitcher.com) ELT platform. For more information, see [singer.io](https://singer.io)


#### Documentation

- [AWS Singer-Taps Readme](../catalog/aws/singer-taps/README.md)

-------------------

### AWS Tableau-Server

#### Overview

This module securely deploys one or more Tableau Servers, which can then be used to host reports in production or POC environments.
The module supports both Linux and Windows versions of the Tableau Server Software.


#### Documentation

- [AWS Tableau-Server Readme](../catalog/aws/tableau-server/README.md)

-------------------



## Azure Catalog

_(Coming soon)_

## GCP Catalog

_(Coming soon)_

-------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs`. Please do not attempt to manually update
this file._

