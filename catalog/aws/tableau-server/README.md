## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | n/a | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | n/a | `string` | n/a | yes |
| admin\_cidr | n/a | `list` | `[]` | no |
| default\_cidr | n/a | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| ec2\_instance\_storage\_gb | n/a | `number` | `100` | no |
| ec2\_instance\_type | n/a | `string` | `"m4.4xlarge"` | no |
| linux\_https\_domain | n/a | `string` | `""` | no |
| linux\_use\_https | n/a | `bool` | `false` | no |
| num\_linux\_instances | n/a | `number` | `1` | no |
| num\_windows\_instances | n/a | `number` | `0` | no |
| registration\_file | n/a | `string` | `"../../.secrets/registration.json"` | no |
| resource\_tags | n/a | `map` | `{}` | no |
| windows\_https\_domain | n/a | `string` | `""` | no |
| windows\_use\_https | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| ec2\_instance\_ids | n/a |
| ec2\_instance\_private\_ips | n/a |
| ec2\_instance\_public\_ips | n/a |
| ec2\_instance\_states | n/a |
| ec2\_remote\_admin\_commands | n/a |
| ec2\_windows\_instance\_passwords | n/a |
| ssh\_private\_key\_path | n/a |
| ssh\_public\_key\_path | n/a |
| summary | output "ssh\_key\_name" { value = var.num\_linux\_instances == 0 ? "n/a" : module.linux\_tableau\_servers[0].key\_name } TODO: Detect EC2 Pricing output "ec2\_instance\_hr\_base\_price" { # estimated base price of the (linux) instance type, excluding upcharge for Windows instance and excluding any special pricing or reservation discounts. value = module.linux\_tableau\_servers.instance\_hr\_list\_price } |

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
