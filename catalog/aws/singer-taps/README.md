
# AWS Singer-Taps

`/catalog/aws/singer-taps`

## Overview


The Singer Taps platform is the open source stack which powers the [Stitcher](https://www.stitcher.com) ELT platform. For more information, see [singer.io](https://singer.io)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| container\_command | n/a | `any` | n/a | yes |
| container\_entrypoint | n/a | `any` | n/a | yes |
| container\_image | n/a | `any` | n/a | yes |
| data\_lake\_metadata\_path | The remote folder for storing tap definitions files.<br>Currently only S3 paths (s3://...) are supported. | `string` | n/a | yes |
| data\_lake\_storage\_path | The path to where files should be stored in the data lake.<br>Note:  - currently only S3 paths (S3://...) are supported.data  - You must specify `target` or `data_lake_storage_path` but not both. | `string` | n/a | yes |
| data\_lake\_type | Specify `S3` if loading to an S3 data lake, otherwise leave blank. | `any` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| local\_metadata\_path | The local folder which countains tap definitions files: `data.select` and `plan-*.yml` | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| taps | n/a | <pre>list(object({<br>    id       = string<br>    settings = map(string)<br>    secrets  = map(string)<br>  }))</pre> | n/a | yes |
| target | The definition of which target to load data into.<br>Note: You must specify `target` or `data_lake_storage_path` but not both. | <pre>object({<br>    id       = string<br>    settings = map(string)<br>    secrets  = map(string)<br>  })</pre> | n/a | yes |
| container\_num\_cores | n/a | `number` | `0.5` | no |
| container\_ram\_gb | n/a | `number` | `1` | no |
| data\_file\_naming\_scheme | n/a | `string` | `"{tap}/{table}/v{version}/{file}"` | no |
| scheduled\_sync\_times | A list of one or more daily sync times in `HHMM` format. E.g.: `0400` for 4am, `1600` for 4pm | `list(string)` | `[]` | no |
| scheduled\_timezone | The timezone used in scheduling.<br>Currently the following codes are supported: PST, EST, UTC | `string` | `"PT"` | no |
| state\_file\_naming\_scheme | n/a | `string` | `"{tap}/{table}/state/{tap}-{table}-v{version}-state.json"` | no |

## Outputs

| Name | Description |
|------|-------------|
| summary | n/a |

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
