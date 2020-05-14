
# AWS Singer-Taps

`/catalog/aws/singer-taps`

## Overview


The Singer Taps platform is the open source stack which powers the [Stitcher](https://www.stitcher.com) ELT platform. For more information, see [singer.io](https://singer.io)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| container\_command | Optional. Override the docker image's command. | `any` | n/a | yes |
| container\_entrypoint | Optional. Override the docker image's entrypoint. | `any` | n/a | yes |
| container\_image | Optional. Override the docker image with a custom-managed image. | `any` | n/a | yes |
| data\_lake\_metadata\_path | The remote folder for storing tap definitions files.<br>Currently only S3 paths (s3://...) are supported. | `string` | n/a | yes |
| data\_lake\_storage\_path | The path to where files should be stored in the data lake.<br>Note:  - currently only S3 paths (S3://...) are supported.data  - You must specify `target` or `data_lake_storage_path` but not both. | `string` | n/a | yes |
| data\_lake\_type | Specify `S3` if loading to an S3 data lake, otherwise leave blank. | `any` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| local\_metadata\_path | The local folder which countains tap definitions files: `data.select` and `plan-*.yml` | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| taps | A list of objects with the keys `id` (the name of the tap without the 'tap-' prefix), `settings` (a map of tap settings to their desired values), and `secrets` (same as `settings` but mapping setting names to the location of the secret and not the secret<br>values themselves) | <pre>list(object({<br>    id       = string<br>    settings = map(string)<br>    secrets  = map(string)<br>  }))</pre> | n/a | yes |
| target | The definition of which target to load data into.<br>Note: You must specify `target` or `data_lake_storage_path` but not both. | <pre>object({<br>    id       = string<br>    settings = map(string)<br>    secrets  = map(string)<br>  })</pre> | n/a | yes |
| container\_num\_cores | Optional. Specify the number of cores to use in the container. | `number` | `0.5` | no |
| container\_ram\_gb | Optional. Specify the amount of RAM to be available to the container. | `number` | `1` | no |
| data\_file\_naming\_scheme | The naming pattern to use when landing new files in the data lake. Allowed variables are: `{tap}`, `{table}`, `{version}`, and `{file}`" | `string` | `"{tap}/{table}/v{version}/{file}"` | no |
| scheduled\_sync\_times | A list of one or more daily sync times in `HHMM` format. E.g.: `0400` for 4am, `1600` for 4pm | `list(string)` | `[]` | no |
| scheduled\_timezone | The timezone used in scheduling.<br>Currently the following codes are supported: PST, PDT, EST, UTC | `string` | `"PT"` | no |
| state\_file\_naming\_scheme | The naming pattern to use when writing or updating state files. State files keep track of<br>data recency and are necessary for incremental loading. Allowed variables are: `{tap}`, `{table}`, `{version}`, and `{file}`" | `string` | `"{tap}/{table}/state/{tap}-{table}-v{version}-state.json"` | no |

## Outputs

| Name | Description |
|------|-------------|
| summary | Summary of resources created by this module. |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](main.tf)
* [outputs.tf](outputs.tf)
* [s3-upload.tf](s3-upload.tf)
* [variables.tf](variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
