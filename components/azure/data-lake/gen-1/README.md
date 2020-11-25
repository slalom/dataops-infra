---
parent: Infrastructure Components
title: Data-Lake Gen-1
nav_exclude: false
---
# Data-Lake Gen-1

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/azure/data-lake/gen-1?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/azure/data-lake/gen-1)

## Overview


This data lake implementation creates a Gen1 Data Lake Store if configured.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- azurerm

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

### azure\_location

Description: The location the Data Lake will exist.

Type: `string`

### resource\_group\_name

Description: The name of the Resource Group which the Data Lake will be created within.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

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

### data\_lake\_name

Description: The name of the Data Lake created.

### data\_lake\_type

Description: The generation type of the Data Lake created (i.e. Gen1 or Gen2).

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/data-lake/gen-1/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/data-lake/gen-1/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/data-lake/gen-1/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
