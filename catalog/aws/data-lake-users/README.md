
# AWS Data-Lake-Users

`/catalog/aws/data-lake-users`

## Overview


Automates the management of users and groups in an S3 data lake.

* Designed to be used in combination with the `aws/data-lake` module.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- local

- aws

## Required Inputs

The following input variables are required:

### name\_prefix

Description: Standard `name_prefix` module input.

Type: `string`

### environment

Description: Standard `environment` module input.

Type:

```hcl
object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
```

### resource\_tags

Description: Standard `resource_tags` module input.

Type: `map(string)`

### data\_bucket

Description: The name of the S3 bucket to which users will be granted access.

Type: `string`

### group\_permissions

Description: Mapping of group names to list of objects containing the applicable permissions.

Example:

```
  group_permissions = {
    uploaders = [
      {
        path  = "data/uploads/"
        read  = true
        write = true
      }
    ]
    global_readers = [
      {
        path  = "/"
        read  = true
        write = false
      }
    ]
    global_writers = [
      {
        path  = "/"
        read  = true
        write = true
      }
    ]
  }
```

Type:

```hcl
map(list(object({
    path  = string
    read  = bool
    write = bool
  })))
```

### users

Description: A set (unique list) of user IDs.

Type: `set(string)`

### user\_groups

Description: A mapping of user IDs to group name.
Example:

```
{
  jake = ["global_readers"]
  jane = ["global_readers", "uploader"]
}
```

Type: `map(list(string))`

### admin\_keybase\_id

Description: The default keybase.io user ID to use for PGP password encryption.

If you do not yet have keybase ID, please install Keybase and then use Keybase to publish a new PGP key.

To install Keybase:
 - Windows Users: choco install keybase
 - MacOSX Users:  brew cask install keybase

To generate and publish a PGP key:
 > keybase pgp gen

Type: `string`

## Optional Inputs

No optional input.

## Outputs

The following outputs are exported:

### aws\_secret\_secret\_access\_keys

Description: Mapping of user IDs to their secret access keys (encrypted).

### summary

Description: Standard Output. Human-readable summary of what was created
by the module and (when applicable) how to access those
resources.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/data-lake-users/iam.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/data-lake-users/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/data-lake-users/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/data-lake-users/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
