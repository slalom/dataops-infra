---
parent: Infrastructure Components
title: Azure Resource-Group
nav_exclude: false
---
# Azure Resource-Group

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/azure/resource-group?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/azure/resource-group)

## Overview


This is the underlying technical component which supports the Resource Group catalog module.

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

### azure\_location

Description: The location the Storage Account will exist.

Type: `string`

### resource\_group\_name

Description: The name of the Resource Group to be created.

Type: `string`

## Optional Inputs

No optional input.

## Outputs

The following outputs are exported:

### resource\_group\_name

Description: The name of the new Resource Group created.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/resource-group/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/resource-group/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/resource-group/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
