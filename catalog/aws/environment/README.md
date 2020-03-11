
# AWS Environment

`/catalog/aws/environment`

## Overview


The environment module sets up common infrastrcuture like VPCs and network subnets. The `envrionment` output
from this module is designed to be passed easily to downstream modules, streamlining the reuse of these core components.

## Providers

No provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aws\_profile | Optional, unless set at the main AWS provider level in which case it is required. | `string` | n/a | yes |
| aws\_region | n/a | `any` | n/a | yes |
| name\_prefix | n/a | `string` | n/a | yes |
| secrets\_folder | n/a | `string` | n/a | yes |
| disabled | As a workaround for unsupported 'count' feature in terraform modules, this switch can be used to disable the module entirely. | `bool` | `false` | no |
| resource\_tags | n/a | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_credentials\_file | n/a |
| environment | n/a |
| is\_windows\_host | n/a |
| ssh\_private\_key\_filename | n/a |
| ssh\_public\_key\_filename | n/a |
| summary | n/a |
| user\_home | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
