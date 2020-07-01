
# AWS Singer-Taps

`/catalog/aws/singer-taps`

## Overview


The Singer Taps platform is the open source stack which powers the [Stitcher](https://www.stitcher.com) ELT platform. For more information, see [singer.io](https://singer.io)

## Requirements

No requirements.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| data\_lake\_metadata\_path | The remote folder for storing tap definitions files.<br>Currently only S3 paths (s3://...) are supported. | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| local\_metadata\_path | The local folder which countains tap definitions files: `{tap-name}.rules.txt` and `{tap-name}.plan.yml` | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| taps | A list of objects with the keys `id` (the name of the tap without the 'tap-' prefix),<br>`settings` (a map of tap settings to their desired values), and `secrets` (same as<br>`settings` but mapping setting names to the location of the secret and not the secret<br>values themselves) | <pre>list(object({<br>    id       = string<br>    settings = map(string)<br>    secrets  = map(string)<br>  }))</pre> | n/a | yes |
| container\_args | Optional. A list of additional args to send to the container. | `list(string)` | <pre>[<br>  "--config_file=False",<br>  "--target_config_file=False"<br>]</pre> | no |
| container\_command | Optional. Override the docker image's command. | `any` | `null` | no |
| container\_entrypoint | Optional. Override the docker image's entrypoint. | `any` | `null` | no |
| container\_image | Optional. Override the docker image with a custom-managed image. | `any` | `null` | no |
| container\_num\_cores | Optional. Specify the number of cores to use in the container. | `number` | `0.5` | no |
| container\_ram\_gb | Optional. Specify the amount of RAM to be available to the container. | `number` | `1` | no |
| data\_file\_naming\_scheme | The naming pattern to use when landing new files in the data lake. Allowed variables are:<br>`{tap}`, `{table}`, `{version}`, and `{file}`" | `string` | `"{tap}/{table}/v{version}/{file}"` | no |
| data\_lake\_storage\_path | The path to where files should be stored in the data lake.<br>Note:<br> - currently only S3 paths (S3://...) are supported.data<br> - You must specify `target` or `data_lake_storage_path` but not both. | `string` | `null` | no |
| data\_lake\_type | Specify `S3` if loading to an S3 data lake, otherwise leave blank. | `any` | `null` | no |
| num\_retries | Optional. The number of retries to attempt if the task fails. | `number` | `0` | no |
| pipeline\_version\_number | Optional. (Default="1") Specify a pipeline version number when there are breaking changes which require<br>isolation. Note if you want to avoid overlap between versions, be sure to (1) cancel the<br>previous version and (2) specify a `start_date` on the new version which is not duplicative<br>of the previously covered time period. | `string` | `"1"` | no |
| scheduled\_sync\_times | A list of one or more daily sync times in `HHMM` format. E.g.: `0400` for 4am, `1600` for 4pm | `list(string)` | `[]` | no |
| scheduled\_timezone | The timezone used in scheduling.<br>Currently the following codes are supported: PST, PDT, EST, UTC | `string` | `"PT"` | no |
| state\_file\_naming\_scheme | The naming pattern to use when writing or updating state files. State files keep track of<br>data recency and are necessary for incremental loading. Allowed variables are:<br>`{tap}`, `{table}`, `{version}`, and `{file}`" | `string` | `"{tap}/{table}/state/{tap}-{table}-v{version}-state.json"` | no |
| target | The definition of which target to load data into.<br>Note: You must specify `target` or `data_lake_storage_path` but not both. | <pre>object({<br>    id       = string<br>    settings = map(string)<br>    secrets  = map(string)<br>  })</pre> | `null` | no |
| timeout\_hours | Optional. The number of hours before the sync task is canceled and retried. | `number` | `48` | no |
| use\_private\_subnet | If True, tasks will use a private subnet and will require a NAT gateway to pull the docker<br>image, and for any outbound traffic. If False, tasks will use a public subnet and will<br>not require a NAT gateway. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| summary | Summary of resources created by this module. |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [cloudwatch.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/singer-taps/cloudwatch.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/singer-taps/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/singer-taps/outputs.tf)
* [s3-upload.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/singer-taps/s3-upload.tf)
* [step-functions.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/singer-taps/step-functions.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/singer-taps/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
