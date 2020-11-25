---
parent: Infrastructure Components
title: Storage Queue
nav_exclude: false
---
# Storage Queue

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/azure/storage/queue?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/azure/storage/queue)

## Overview


This is the underlying technical component which supports the Storage catalog module for
building Queue Storage.

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

Description: The name of the Storage Account the Queue(s) will be created under.

Type: `string`

### queue\_storage\_names

Description: Names of Queues to be created.

Type: `list(string)`

## Optional Inputs

No optional input.

## Outputs

The following outputs are exported:

### queue\_storage\_names

Description: The name of the Queue(s) created.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/storage/queue/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/storage/queue/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/storage/queue/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
