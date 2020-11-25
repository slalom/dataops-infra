---
parent: Infrastructure Components
title: Azure Storage-Account
nav_exclude: false
---
# Azure Storage-Account

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/azure/storage-account?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/azure/storage-account)

## Overview


This is the underlying technical component which supports the Storage Account catalog module.

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

Description: The name of the Resource Group which the Storage Account will be created within.

Type: `string`

### storage\_account\_name

Description: The name of the Storage Account to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### account\_tier

Description: Defines the tier to use for this Storage Account.

Type: `string`

Default: `"Standard"`

### account\_replication\_type

Description: The type of replication to use for this Storage Account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS.

Type: `string`

Default: `"GZRS"`

### account\_kind

Description: The kind of Storage Account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2.

Type: `string`

Default: `"StorageV2"`

### access\_tier

Description: The access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool.

Type: `string`

Default: `"Hot"`

### enable\_https\_traffic\_only

Description: Boolean flag which forces HTTPS if enabled.

Type: `bool`

Default: `true`

### allow\_blob\_public\_access

Description: Allow or disallow public access to all Blobs or Containers in the Storage Account.

Type: `bool`

Default: `false`

### is\_hns\_enabled

Description: Defines whether Hierarchical Namespace is enabled. Typically used with Azure Data Lake Storage Gen 2.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### storage\_account\_name

Description: The name of the new Storage Account created.

### storage\_account\_id

Description: The ID for the new Storage Account created.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/storage-account/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/storage-account/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/azure/storage-account/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
