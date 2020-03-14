
# AWS EC2

`/components/aws/ec2`

## Overview


EC2 is the virtual machine layer of the AWS platform. This module allows you to pass your own startup scripts, and it streamlines the creation and usage of
credentials (passwords and/or SSH keypairs) needed to connect to the instances.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| ami\_name\_filter | n/a | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| instance\_type | n/a | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| ssh\_key\_name | n/a | `string` | n/a | yes |
| ssh\_private\_key\_filepath | n/a | `string` | n/a | yes |
| admin\_cidr | n/a | `list` | `[]` | no |
| admin\_ports | n/a | `map` | <pre>{<br>  "SSH": "22"<br>}</pre> | no |
| ami\_owner | n/a | `string` | `"amazon"` | no |
| app\_cidr | n/a | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| app\_ports | map of port descriptions to port numbers (e.g. 22) or ranges (e.g. '0:65535') | `map` | `{}` | no |
| file\_resources | List of files to needed on the instance (e.g. 'http://url/to/remote/file', '/path/to/local/file', '/path/to/local/file:renamed') | `list` | `[]` | no |
| https\_domain | n/a | `string` | `""` | no |
| instance\_storage\_gb | n/a | `number` | `100` | no |
| is\_windows | n/a | `bool` | `false` | no |
| num\_instances | n/a | `number` | `1` | no |
| use\_https | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_id | n/a |
| instance\_ids | n/a |
| instance\_state | n/a |
| instance\_states | n/a |
| private\_ip | n/a |
| private\_ips | n/a |
| public\_ip | TODO: Detect EC2 Pricing output "instance\_hr\_list\_price" { value = local.price\_per\_instance\_hr } |
| public\_ips | n/a |
| remote\_admin\_commands | n/a |
| ssh\_key\_name | n/a |
| ssh\_private\_key\_path | n/a |
| ssh\_public\_key\_path | n/a |
| windows\_instance\_passwords | n/a |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
