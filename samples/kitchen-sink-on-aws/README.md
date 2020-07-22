
# Samples Kitchen-Sink-On-AWS

`/samples/kitchen-sink-on-aws`

## Overview


## Requirements

The following requirements are needed by this module:

- aws (~> 2.10)

## Providers

The following providers are used by this module:

- local

## Required Inputs

No required input.

## Optional Inputs

No optional input.

## Outputs

The following outputs are exported:

### data\_lake\_summary

Description: n/a

### airflow\_summary

Description: n/a

### tap\_to\_rs\_summary

Description: n/a

### summary

Description: n/a

### env\_summary

Description: n/a

---------------------

## Source Files

_Source code for this module is available using the links below._

* [00_environment.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//samples/kitchen-sink-on-aws/00_environment.tf)
* [01_data-lake.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//samples/kitchen-sink-on-aws/01_data-lake.tf)
* [02_redshift.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//samples/kitchen-sink-on-aws/02_redshift.tf)
* [03_airflow.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//samples/kitchen-sink-on-aws/03_airflow.tf)
* [05_extract-to-redshift.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//samples/kitchen-sink-on-aws/05_extract-to-redshift.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
