
# AWS VPC

`/components/aws/vpc`

## Overview


The VPC module creates a number of network services which support other key AWS functions.

Included automatically when creating this module:
* 1 VPC which contains the following:
    * 2 private subnets (for resources which **do not** need a public IP address)
    * 2 public subnets (for resources which do need a public IP address)
    * 1 NAT gateway (allows private subnet resources to reach the outside world)
    * 1 Intenet gateway (allows resources in public and private subnets to reach the internet)
    * route tables and routes to connect all of the above

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aws\_credentials\_file | Optional, unless set at the main AWS provider level in which case it is required. | `string` | n/a | yes |
| aws\_profile | Optional, unless set at the main AWS provider level in which case it is required. | `string` | n/a | yes |
| aws\_region | Optional. Overrides the AWS region, otherwise will use the AWS region provided from context. | `any` | n/a | yes |
| environment | Standard `environment` module input. (Ignored for the `vpc` module.) | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| subnet\_cidrs | Optional. The CIDR blocks to use for the subnets.<br>The list should have the 2 public subnet cidrs first, followed by the 2 private subnet cidrs.<br>If omitted, the VPC CIDR block will be split evenly into 4 equally-sized subnets. | `list(string)` | n/a | yes |
| disabled | As a workaround for unsupported 'count' feature in terraform modules, this switch can be used to disable the module entirely. | `bool` | `false` | no |
| vpc\_cidr | Optional. The CIDR block to use for the VPC network. | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| private\_route\_table | The ID of the route table for private subnets. |
| private\_subnets | The list of private subnets. |
| public\_route\_table | The ID of the route table for public subnets. |
| public\_subnets | The list of public subnets. |
| vpc\_id | The unique ID of the VPC. |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/vpc/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/vpc/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//components/aws/vpc/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
