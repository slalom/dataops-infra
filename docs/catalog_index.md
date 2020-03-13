
# DataOps Infrastructure Catalog

The Infrastructure Catalog contains ready-to-deploy terraform modules for a variety of production data project use cases and POCs. For information about the technical building blocks used in these modules, please see the catalog [components index](components_index.md).

## Contents

1. [AWS Catalog](#aws-catalog)
    - [AWS Airflow](#aws-airflow)
    - [AWS Data-Lake](#aws-data-lake)
    - [AWS DBT](#aws-dbt)
    - [AWS Environment](#aws-environment)
    - [AWS MySQL](#aws-mysql)
    - [AWS Postgres](#aws-postgres)
    - [AWS Redshift](#aws-redshift)
    - [AWS Singer-Taps](#aws-singer-taps)
    - [AWS Tableau-Server](#aws-tableau-server)

2. Azure Catalog
    * _(Coming soon)_
2. GCP Catalog
    * _(Coming soon)_

## AWS Catalog

### [AWS Airflow](../catalog/aws/airflow/README.md)

Airflow is an open source platform to programmatically author, schedule and monitor workflows. More information here: [airflow.apache.org](https://airflow.apache.org/)


* Source: `git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/airflow?ref=master`
* See the [AWS Airflow Readme](../catalog/aws/airflow/README.md) for input/output specs and additional info.

-------------------

### [AWS Data-Lake](../catalog/aws/data-lake/README.md)

This data lake implementation creates three buckets, one each for data, logging, and metadata. The data lake also supports lambda functions which can
trigger automatically when new content is added.


* Source: `git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/data-lake?ref=master`
* See the [AWS Data-Lake Readme](../catalog/aws/data-lake/README.md) for input/output specs and additional info.

-------------------

### [AWS DBT](../catalog/aws/dbt/README.md)

DBT (Data Built Tool) is a CI/CD and DevOps-friendly platform for automating data transformations. More info at [www.getdbt.com](https://www.getdbt.com).



* Source: `git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/dbt?ref=master`
* See the [AWS DBT Readme](../catalog/aws/dbt/README.md) for input/output specs and additional info.

-------------------

### [AWS Environment](../catalog/aws/environment/README.md)

The environment module sets up common infrastrcuture like VPCs and network subnets. The `envrionment` output
from this module is designed to be passed easily to downstream modules, streamlining the reuse of these core components.



* Source: `git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/environment?ref=master`
* See the [AWS Environment Readme](../catalog/aws/environment/README.md) for input/output specs and additional info.

-------------------

### [AWS MySQL](../catalog/aws/mysql/README.md)

Deploys a MySQL server running on RDS.

* NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

* Source: `git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/mysql?ref=master`
* See the [AWS MySQL Readme](../catalog/aws/mysql/README.md) for input/output specs and additional info.

-------------------

### [AWS Postgres](../catalog/aws/postgres/README.md)

Deploys a Postgres server running on RDS.

* NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

* Source: `git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/postgres?ref=master`
* See the [AWS Postgres Readme](../catalog/aws/postgres/README.md) for input/output specs and additional info.

-------------------

### [AWS Redshift](../catalog/aws/redshift/README.md)

Redshift is an AWS database platform which applies MPP (Massively-Parallel-Processing) principles to big data workloads in the cloud.


* Source: `git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/redshift?ref=master`
* See the [AWS Redshift Readme](../catalog/aws/redshift/README.md) for input/output specs and additional info.

-------------------

### [AWS Singer-Taps](../catalog/aws/singer-taps/README.md)

The Singer Taps platform is the open source stack which powers the [Stitcher](https://www.stitcher.com) ELT platform. For more information, see [singer.io](https://singer.io)


* Source: `git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/singer-taps?ref=master`
* See the [AWS Singer-Taps Readme](../catalog/aws/singer-taps/README.md) for input/output specs and additional info.

-------------------

### [AWS Tableau-Server](../catalog/aws/tableau-server/README.md)

This module securely deploys one or more Tableau Servers, which can then be used to host reports in production or POC environments.
The module supports both Linux and Windows versions of the Tableau Server Software.


* Source: `git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/tableau-server?ref=master`
* See the [AWS Tableau-Server Readme](../catalog/aws/tableau-server/README.md) for input/output specs and additional info.

-------------------



## Azure Catalog

_(Coming soon)_

## GCP Catalog

_(Coming soon)_

-------------------

_**NOTE:** This documentation was [auto-generated](build.py) using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._

