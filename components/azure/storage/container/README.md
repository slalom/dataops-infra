---
parent: Infrastructure Components
title: Storage Container
nav_exclude: false
---
# Storage Container

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/azure/storage/container?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/azure/storage/container)

## Overview


This is the underlying technical component which supports the Storage catalog module for
building Containers.

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

### storage\_account\_name

Description: The name of the Storage Account the Storage Container(s) will be created under.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### container\_names

Description: Names of Storage Containers to be created.

Type: `list(string)`

Default: `[]`

### container\_access\_type

Description: The access level configured for the Storage Container(s). Possible values are blob, container or private.

Type: `string`

Default: `"private"`

## Outputs

The following outputs are exported:

### container\_names

Description: The name of the Storage Container(s) created.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/storage/container/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/storage/container/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/storage/container/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
