
# AWS Singer-Taps

`/catalog/aws/singer-taps`

## Overview


The Singer Taps platform is the open source stack which powers the [Stitcher](https://www.stitcher.com) ELT platform. For more information, see [singer.io](https://singer.io)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aws\_region | n/a | `any` | n/a | yes |
| container\_command | n/a | `any` | n/a | yes |
| container\_entrypoint | n/a | `any` | n/a | yes |
| container\_image | n/a | `any` | n/a | yes |
| environment | n/a | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | n/a | `string` | n/a | yes |
| source\_code\_folder | n/a | `string` | n/a | yes |
| source\_code\_s3\_bucket | n/a | `string` | n/a | yes |
| taps | n/a | <pre>list(object({<br>    id       = string<br>    settings = map(string)<br>    secrets  = map(string)<br>  }))</pre> | n/a | yes |
| container\_num\_cores | n/a | `number` | `0.5` | no |
| container\_ram\_gb | n/a | `number` | `1` | no |
| resource\_tags | n/a | `map` | `{}` | no |
| scheduled\_sync\_times | A list of schedule strings in 4 digit format: HHMM | `list(string)` | `[]` | no |
| scheduled\_timezone | n/a | `string` | `"PT"` | no |
| source\_code\_s3\_path | n/a | `string` | `"code/taps"` | no |
| target | n/a | <pre>object({<br>    id       = string<br>    settings = map(string)<br>    secrets  = map(string)<br>  })</pre> | <pre>{<br>  "id": "s3-csv",<br>  "secrets": {},<br>  "settings": {<br>    "s3_key_prefix": "data/raw/{tap}/{table}/{version}/"<br>  }<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| summary | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
