---
parent: Infrastructure Catalog
title: Azure Data-Lake
nav_exclude: false
---
# Azure Data-Lake

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/azure/data-lake?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/azure/data-lake)

## Overview


Deploys either a Gen1 or Gen2 Data Lake Store.

## Requirements

No requirements.

## Providers

No provider.

## Required Inputs

The following input variables are required:

### name\_prefix

Description: Standard `name_prefix` module input.

Type: `string`

### resource\_tags

Description: Standard `resource_tags` module input.

Type: `map(string)`

### data\_lake\_name

Description: The name of the Data Lake that will be created.

Type: `string`

### data\_lake\_type

Description: The type of Data Lake to be created.  Possible values are Gen1 or Gen2.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### azure\_location

Description: The location the Data Lake will exist.

Type: `string`

Default: `""`

### resource\_group\_name

Description: The name of the Resource Group which the Data Lake will be created within.

Type: `string`

Default: `""`

### storage\_account\_id

Description: The ID for the Storage Account in which this Data Lake will be created.

Type: `string`

Default: `""`

### encryption\_state

Description: Defines whether exncryption is enabled on this Data Lake account. Possible values are Enabled or Disabled.

Type: `string`

Default: `"Enabled"`

### firewall\_allow\_azure\_ips

Description: Defines whether Azure Service IPs are allowed through the firewall. Possible values are Enabled and Disabled.

Type: `string`

Default: `"Enabled"`

### firewall\_state

Description: The state of the firewall for the Data Lake. Possible values are Enabled and Disabled.

Type: `string`

Default: `"Enabled"`

## Outputs

The following outputs are exported:

### summary

Description: Summary of resources created by this module.

### data\_lake\_name

Description: The Data Lake name value(s) of the newly created Data Lake(s).

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/azure/data-lake/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/azure/data-lake/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/azure/data-lake/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
