---
parent: Infrastructure Catalog
title: AWS Singer-Taps
nav_exclude: false
---
# AWS Singer-Taps

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/aws/singer-taps?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/aws/singer-taps)

## Overview


The Singer Taps platform is the open source stack which powers the [Stitcher](https://www.stitcher.com) EL platform. For more information, see [singer.io](https://singer.io)

## Requirements

No requirements.

## Providers

The following providers are used by this module:

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

### taps

Description: A list of objects with the following keys:

- `id`       - The name of the tap without the 'tap-' prefix.
- `schedule` - A list of one or more daily sync times in `HHMM` format. E.g.: `0400` for 4am, `1600` for 4pm.
- `settings` - A map of tap settings to their values.
- `secrets`  - A map of secret names to the location (file:key) of the secrets (not the secret values themselves)

Type:

```hcl
list(object({
    id       = string
    schedule = list(string)
    settings = map(string)
    secrets  = map(string)
  }))
```

### local\_metadata\_path

Description: The local folder which countains tap definitions files: `{tap-name}.rules.txt` and `{tap-name}.plan.yml`

Type: `string`

### data\_lake\_metadata\_path

Description: The remote folder for storing tap definitions files.
Currently only S3 paths (s3://...) are supported.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### target

Description: The definition of which target to load data into.
Note: You must specify `target` or `data_lake_storage_path` but not both.

Type:

```hcl
object({
    id       = string
    settings = map(string)
    secrets  = map(string)
  })
```

Default: `null`

### pipeline\_version\_number

Description: Optional. (Default="1") Specify a pipeline version number when there are breaking changes which require
isolation. Note if you want to avoid overlap between versions, be sure to (1) cancel the
previous version and (2) specify a `start_date` on the new version which is not duplicative
of the previously covered time period.

Type: `string`

Default: `"1"`

### data\_lake\_type

Description: Specify `S3` if loading to an S3 data lake, otherwise leave blank.

Type: `any`

Default: `null`

### data\_lake\_storage\_path

Description: The root path where files should be stored in the data lake.
Note:
 - Currently only S3 paths (S3://...) are supported.
 - You must specify `target` or `data_lake_storage_path` but not both.
 - This path will be combined with the value provided in `data_file_naming_scheme`.

Type: `string`

Default: `null`

### scheduled\_timezone

Description: The timezone used in scheduling.
Currently the following codes are supported: PST, PDT, EST, UTC

Type: `string`

Default: `"PST"`

### timeout\_hours

Description: Optional. The number of hours before the sync task is canceled and retried.

Type: `number`

Default: `48`

### num\_retries

Description: Optional. The number of retries to attempt if the task fails.

Type: `number`

Default: `0`

### container\_num\_cores

Description: Optional. Specify the number of cores to use in the container.

Type: `number`

Default: `0.5`

### container\_ram\_gb

Description: Optional. Specify the amount of RAM to be available to the container.

Type: `number`

Default: `1`

### use\_private\_subnet

Description: If True, tasks will use a private subnet and will require a NAT gateway to pull the docker
image, and for any outbound traffic. If False, tasks will use a public subnet and will
not require a NAT gateway.

Type: `bool`

Default: `false`

### data\_file\_naming\_scheme

Description: The naming pattern to use when landing new files in the data lake. Allowed variables are:
`{tap}`, `{table}`, `{version}`, and `{file}`. This value will be combined with the root
data lake path provided in `data_lake_storage_path`."

Type: `string`

Default: `"{tap}/{table}/v{version}/{file}"`

### state\_file\_naming\_scheme

Description: The naming pattern to use when writing or updating state files. State files keep track of
data recency and are necessary for incremental loading. Allowed variables are:
`{tap}`, `{table}`, `{version}`, and `{file}`"

Type: `string`

Default: `"{tap}/{table}/state/{tap}-{table}-v{version}-state.json"`

### container\_image\_override

Description: Optional. Override the docker images with a custom-managed image.

Type: `string`

Default: `null`

### container\_image\_suffix

Description: Optional. Appends a suffix to the default container images.
(e.g. '--pre' for prerelease containers)

Type: `string`

Default: `""`

### container\_command

Description: Optional. Override the docker image's command.

Type: `any`

Default: `null`

### container\_args

Description: Optional. A list of additional args to send to the container.

Type: `list(string)`

Default:

```json
[
  "--config_file=False",
  "--target_config_file=False"
]
```

### container\_entrypoint

Description: Optional. Override the docker image's entrypoint.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### summary

Description: Summary of resources created by this module.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [cloudwatch.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/singer-taps/cloudwatch.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/singer-taps/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/singer-taps/outputs.tf)
* [s3-path-parsing.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/singer-taps/s3-path-parsing.tf)
* [s3-upload.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/singer-taps/s3-upload.tf)
* [step-functions.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/singer-taps/step-functions.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/singer-taps/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
