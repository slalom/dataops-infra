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

Description: Standard `name_prefix` module input. (Prefix counts towards 64-character max length for certain resource types.)

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

Description: A list of tap configurations with the following setting keys:

- `id`       - The official id of the tap plugin to be used, without the 'tap-' prefix.
- `name`     - The friendly name of the tap, without the 'tap-' prefix.
- `schedule` - A list of one or more daily sync times in `HHMM` format. E.g.: `0400` for 4am, `1600` for 4pm.
- `settings` - Map of tap settings to their values.
- `secrets`  - Map of secrets names mapped to any of the following:
               A. file path ("path/to/file") that contains a matching key name,
               B. the file path and the json/yaml key ("path/to/file:key"),
               C. the AWS Secrets Manager ID of an already stored secret

Type:

```hcl
list(object({
    id       = string
    name     = string
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
See the 'taps' input variable for more information on expected configuration values.

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

### data\_lake\_logging\_path

Description: The remote folder for storing tap execution logs and log artifacts.
Currently only S3 paths (s3://...) are supported.

Type: `string`

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

Default: `[]`

### container\_entrypoint

Description: Optional. Override the docker image's entrypoint.

Type: `string`

Default: `null`

### alerts\_webhook\_url

Description: Optionally, specify a webhook for MS Teams notifications.

Type: `string`

Default: `null`

### alerts\_webhook\_message

Description: Optionally, specify a message for webhook notifications.

Type: `string`

Default: `"Warning: A failure occured in the pipeline. Please check on it using the information below.\n"`

### success\_webhook\_url

Description: Optionally, specify a webhook for MS Teams notifications.

Type: `string`

Default: `null`

### success\_webhook\_message

Description: Optionally, specify a message for webhook notifications.

Type: `string`

Default: `"Success! The pipeline completed successfully.\n"`

## Outputs

The following outputs are exported:

### summary

Description: Summary of resources created by this module.
## Usage

This module supports multiple taps per each target. To target multiple destinations, simply create
additional instances of the module.

### Tap configuration overview

The `taps` input variable expects a list of specifications for each tap. The specification for each
tap should include the following properties:

- `id` - The name or alias of the tap as registered in the [Singer Index](#singer-index), without the `tap-` prefix.
  - Note: in most cases, this is exactly what you'd expect: `mssql` for `tap-mssql`, etc. However,
    for forks or experimental releases, this might contain a suffix such as `mssql-test` for a test
    version of `tap-mssql` or `snowflake-singer` for the singer edition of `tap-snowflake`.
  - A future release will add a separate and optional flag for `owner` or `variant`, in place of the
    currently used alias/suffix convention. See the [Singer Index](#singer-index) section for more
    info.
- `name` - What you want to call the data source. For instance, if you have multiple SQL Servers, you may want to use a more memorable name such as `finance-system` or `gl-db`. This name should still align with tap naming conventions, which is to say it should be in _lower-case-with-dashes_ format.
- `settings` - A simple map of the tap settings' names to their values. These are specific to each tap and they are required for each tap to work.
  - Note: While singer does not distinguish between 'secrets' and 'settings', we should and do treat these two types of config separately. Be sure to put all sensitive config in the `secrets` collection, and not here in `settings`.
- `secrets` - Same as `config` except for sensitive values. When passing secrets, you specify the setting name in the same way but you _must_ either pass the value as a pointer to the file containing the secret (a config.json file, for instance) or else pass a AWS Secrets Manager ARN.
  - _If you pass a Secrets Manager ARN as the config value_, that secret pointer will be passed to the ECS container securely, and only the running container will have access to the secret.
  - _If you pass a pointer to a config file_, the module will automatically create a new AWS Secrets Manager secret, upload the secret to AWS Secrets Manager, and then the above process will continue by passing the Secrets Manager pointer _only_ to the running ECS container.

### Singer Index

There are actually two Singer Indexes currently available.

1. The first and primary index for this module today is the tapdance index stored [here](https://github.com/aaronsteers/tapdance/blob/master/docker/singer_index.yml).

2. This index will be eventually be replaced by a new dedicated [Singer DB](https://github.com/aaronsteers/singer-db), which is still a work-in-progress.

Note:

- Both of these sources support multiple versions (forks) of each tap, and both provide a "default"
  or "recommended" version for those new users who just want to get started quickly.
- The new [Singer DB](https://github.com/aaronsteers/singer-db) will implement a new "owner" or "variant"
  flag to replace the current "alias" technique used by the
  [tapdance index](https://github.com/aaronsteers/tapdance/blob/master/docker/singer_index.yml).


---------------------

## Source Files

_Source code for this module is available using the links below._

* [cloudwatch.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/singer-taps/cloudwatch.tf)
* [lambda-notify.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/singer-taps/lambda-notify.tf)
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
