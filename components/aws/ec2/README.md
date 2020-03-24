
# AWS EC2

`/components/aws/ec2`

## Overview


EC2 is the virtual machine layer of the AWS platform. This module allows you to pass your own startup scripts, and it streamlines the creation and usage of
credentials (passwords and/or SSH keypairs) needed to connect to the instances.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| ami\_name\_filter | A name filter used when searching for the EC2 AMI ('\*' used as wildcard). | `string` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| instance\_type | The desired EC2 instance type. | `string` | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| ssh\_key\_name | The name of a SSH key pair which has been uploaded to AWS. This is used to access Linux instances remotely. | `string` | n/a | yes |
| ssh\_private\_key\_filepath | The local private key file for the SSH key pair which has been uploaded to AWS. This is used to access Linux instances remotely. | `string` | n/a | yes |
| admin\_cidr | Optional. The IP address range(s) which should have access to the admin<br>on the instance(s). By default this will default to only allow connections<br>from the terraform user's current IP address. | `list` | `[]` | no |
| admin\_ports | A map defining the admin ports which should be goverened by `admin_cidr`. Single ports (e.g. '22') and port ranges (e.g. '0:65535') and both supported. | `map` | <pre>{<br>  "SSH": "22"<br>}</pre> | no |
| ami\_owner | The name or account number of the owner who publishes the AMI. | `string` | `"amazon"` | no |
| app\_cidr | Optional. The IP address range(s) which should have access to the non-admin ports (such as end-user http portal). If not set, this will default to allow incoming<br>connections from any IP address (['0.0.0.0/0']). In general, this should be omitted<br>unless the site has a VPN or other internal list of IP whitelist ranges. | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| app\_ports | A map defining the end-user ports which should be goverened by `app_cidr`. Single ports (e.g. '22') and port ranges (e.g. '0:65535') and both supported. | `map` | `{}` | no |
| file\_resources | List of files to needed on the instance (e.g. 'http://url/to/remote/file', '/path/to/local/file', '/path/to/local/file:renamed') | `list` | `[]` | no |
| https\_domain | If `use_https` = True, the https domain for secure web traffic. | `string` | `""` | no |
| instance\_storage\_gb | The desired EC2 instance storage, in GB. | `number` | `100` | no |
| is\_windows | True to launch a Windows instance, otherwise False. | `bool` | `false` | no |
| num\_instances | The number of EC2 instances to launch. | `number` | `1` | no |
| use\_https | True to enable https traffic on the instance. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_id | The instance ID (if `num_instances` == 1). |
| instance\_ids | The list of instance ID created. |
| instance\_state | The state of the instance at time of apply (if `num_instances` == 1). |
| instance\_states | A map of instance IDs to the state of each instance at time of apply. |
| private\_ip | The private IP address (if `num_instances` == 1) |
| private\_ips | A map of EC2 instance IDs to private IP addresses. |
| public\_ip | The public IP address (if applicable, and if `num_instances` == 1) |
| public\_ips | A map of EC2 instance IDs to public IP addresses (if applicable). |
| remote\_admin\_commands | A map of instance IDs to command-line strings which can be used to connect to each instance. |
| ssh\_key\_name | The SSH key name for EC2 remote access. |
| ssh\_private\_key\_path | The local path to the private key file used for EC2 remote access. |
| ssh\_public\_key\_path | The local path to the public key file used for EC2 remote access. |
| windows\_instance\_passwords | A map of instance IDs to Windows passwords (if applicable). |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](main.tf)
* [outputs.tf](outputs.tf)
* [variables.tf](variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
