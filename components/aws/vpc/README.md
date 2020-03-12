
# AWS VPC

`/components/aws/vpc`

## Overview


The VPC module creates a number of network services which support other key AWS functions.

Included automatically when creating this module:
* 1 VPC which contains the following:
    * 2 private subnets (for resources which **do not** need a public IP address)
    * 2 public subnets (for resources which do need a public IP address)
    * 1 NAT gateway (allows private sugnet resources to reach the outside world)
    * 1 Intenet gateway (allows resources in public and private subnets to reach the internet)
    * route tables and routes to connect all of the above

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aws\_credentials\_file | Optional, unless set at the main AWS provider level in which case it is required. | `string` | n/a | yes |
| aws\_profile | Optional, unless set at the main AWS provider level in which case it is required. | `string` | n/a | yes |
| aws\_region | n/a | `any` | n/a | yes |
| environment | Standard `environment` module input. (Ignored for the `vpc` module.) | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | n/a | `string` | n/a | yes |
| disabled | As a workaround for unsupported 'count' feature in terraform modules, this switch can be used to disable the module entirely. | `bool` | `false` | no |
| resource\_tags | n/a | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| private\_subnets | n/a |
| public\_subnets | n/a |
| vpc\_id | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
