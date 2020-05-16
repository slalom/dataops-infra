
# AWS Tableau-Server

`/catalog/aws/tableau-server`

## Overview


This module securely deploys one or more Tableau Servers, which can then be used to host reports in production or POC environments.
The module supports both Linux and Windows versions of the Tableau Server Software.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| admin\_cidr | Optional. The IP address range(s) which should have access to the admin<br>on the Tableau Server instances. By default this will default to only allow<br>connections from the terraform user's current IP address. | `list` | `[]` | no |
| app\_cidr | Optional. The IP address range(s) which should have access to the view the<br>Tableau Server web instance (excluding the TMS admin portal and other admin<br>ports). If not set, this will default to allow incoming connections from<br>any IP address (['0.0.0.0/0']). In general, this should be omitted unless the<br>site has a VPN or other internal list of IP whitelist ranges. | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| ec2\_instance\_storage\_gb | The amount of storage to provision on each instance, in GB. | `number` | `100` | no |
| ec2\_instance\_type | Optional. Overrides the Tableau Server instance type. | `string` | `"m4.4xlarge"` | no |
| linux\_https\_domain | The https domain if the Linux instances should use HTTPS. | `string` | `""` | no |
| linux\_use\_https | True if the Linux instances should use HTTPS. | `bool` | `false` | no |
| num\_linux\_instances | The number of Tableau Server instances to create on Linux. | `number` | `1` | no |
| num\_windows\_instances | The number of Tableau Server instances to create on Windows. | `number` | `0` | no |
| registration\_file | A path to a local or remote file for Tableau registration. | `string` | `"../../.secrets/registration.json"` | no |
| windows\_https\_domain | The https domain if the Windows instances should use HTTPS. | `string` | `""` | no |
| windows\_use\_https | True if the Windows instances should use HTTPS. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| ec2\_instance\_ids | The EC2 intance ID(s) created by the module. |
| ec2\_instance\_private\_ips | The private IP address for each EC2 instance. |
| ec2\_instance\_public\_ips | The public IP address for each EC2 instance (if applicable). |
| ec2\_instance\_states | The current EC2 instance status for each Tableau Server instance, as of time of plan execution. |
| ec2\_remote\_admin\_commands | Command line command to connect to the Tableau Server instance(s) via RDP or SSH. |
| ec2\_windows\_instance\_passwords | The admin passwords for Windows instances (if applicable). |
| ssh\_private\_key\_path | Local path to private key file for connecting to the server via SSH. |
| ssh\_public\_key\_path | Local path to public key file for connecting to the server via SSH. |
| summary | Summary of resources created by this module. |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/tableau-server/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/tableau-server/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/tableau-server/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
