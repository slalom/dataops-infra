---
parent: Infrastructure Catalog
title: Azure Storage
nav_exclude: false
---
# Azure Storage

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/azure/storage?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/azure/storage)

## Overview


Deploys Storage Containers, Queue Storage, and Table Storage within a storage
account.

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

### storage\_account\_name

Description: The name of the Storage Account to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### container\_names

Description: Names of Storage Containers to be created.

Type: `list(string)`

Default: `[]`

### table\_storage\_names

Description: Names of Tables to be created.

Type: `list(string)`

Default: `[]`

### queue\_storage\_names

Description: Names of Queues to be created.

Type: `list(string)`

Default: `[]`

### container\_access\_type

Description: The access level configured for the Storage Container(s). Possible values are blob, container or private.

Type: `string`

Default: `"private"`

## Outputs

The following outputs are exported:

### summary

Description: Summary of resources created by this module.

### storage\_container\_names

Description: The Storage Container name value(s) of the newly created container(s).

### table\_storage\_names

Description: The Table Storage name value(s) of the newly created table(s).

### queue\_storage\_names

Description: The Queue Storage name value(s) of the newly created table(s).

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/azure/storage/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/azure/storage/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/azure/storage/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
