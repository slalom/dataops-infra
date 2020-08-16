
# AWS EC2

`/components/aws/ec2`

## Overview


Flag --no-sort has been deprecated, use '--sort=false' instead
EC2 is the virtual machine layer of the AWS platform. This module allows you to pass your own startup scripts, and it streamlines the creation and usage of
credentials (passwords and/or SSH keypairs) needed to connect to the instances.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- aws

- http

## Required Inputs

The following input variables are required:

### name\_prefix

Description: Standard `name_prefix` module input.

Type: `string`

### environment

Description: Standard `environment` module input.

Type:

```hcl
object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
```

### resource\_tags

Description: Standard `resource_tags` module input.

Type: `map(string)`

### ami\_name\_filter

Description: A name filter used when searching for the EC2 AMI ('\*' used as wildcard).

Type: `string`

### instance\_type

Description: The desired EC2 instance type.

Type: `string`

### ssh\_keypair\_name

Description: The name of a SSH key pair which has been uploaded to AWS. This is used to access Linux instances remotely.

Type: `string`

### ssh\_private\_key\_filepath

Description: The local private key file for the SSH key pair which has been uploaded to AWS. This is used to access Linux instances remotely.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### admin\_cidr

Description: Optional. The IP address range(s) which should have access to the admin
on the instance(s). By default this will default to only allow connections
from the terraform user's current IP address.

Type: `list`

Default: `[]`

### admin\_ports

Description: A map defining the admin ports which should be goverened by `admin_cidr`. Single ports
(e.g. '22') and port ranges (e.g. '0:65535') and both supported.

Type: `map`

Default:

```json
{
  "SSH": "22"
}
```

### app\_cidr

Description: Optional. The IP address range(s) which should have access to the non-admin ports
(such as end-user http portal). If not set, this will default to allow incoming
connections from any IP address (['0.0.0.0/0']). In general, this should be omitted
unless the site has a VPN or other internal list of IP whitelist ranges.

Type: `list`

Default:

```json
[
  "0.0.0.0/0"
]
```

### app\_ports

Description: A map defining the end-user ports which should be goverened by `app_cidr`. Single ports
(e.g. '22') and port ranges (e.g. '0:65535') and both supported.

Type: `map`

Default: `{}`

### cluster\_ports

Description: A map defining which ports should be openen for instances to talk with one another.

Type: `map`

Default: `{}`

### ami\_owner

Description: The name or account number of the owner who publishes the AMI.

Type: `string`

Default: `"amazon"`

### instance\_storage\_gb

Description: The desired EC2 instance storage, in GB.

Type: `number`

Default: `100`

### is\_windows

Description: True to launch a Windows instance, otherwise False.

Type: `bool`

Default: `false`

### file\_resources

Description: List of files to needed on the instance (e.g. 'http://url/to/remote/file', '/path/to/local/file', '/path/to/local/file:renamed')

Type: `list`

Default: `[]`

### https\_domain

Description: If `use_https` = True, the https domain for secure web traffic.

Type: `string`

Default: `""`

### num\_instances

Description: The number of EC2 instances to launch.

Type: `number`

Default: `1`

### use\_https

Description: True to enable https traffic on the instance.

Type: `bool`

Default: `false`

### use\_private\_subnets

Description: If True, EC2 will use a private subnets and will require a NAT gateway to pull the docker
image, and for any outbound traffic. If False, tasks will use a public subnet and will
not require a NAT gateway. Note: a load balancer configuration may also be required in
order for EC2 instances to receive incoming traffic.

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### ssh\_keypair\_name

Description: The SSH key name for EC2 remote access.

### ssh\_private\_key\_path

Description: The local path to the private key file used for EC2 remote access.

### instance\_id

Description: The instance ID (if `num_instances` == 1).

### instance\_ids

Description: The list of instance ID created.

### public\_ip

Description: The public IP address (if applicable, and if `num_instances` == 1)

### public\_ips

Description: A map of EC2 instance IDs to public IP addresses (if applicable).

### private\_ip

Description: The private IP address (if `num_instances` == 1)

### private\_ips

Description: A map of EC2 instance IDs to private IP addresses.

### instance\_state

Description: The state of the instance at time of apply (if `num_instances` == 1).

### instance\_states

Description: A map of instance IDs to the state of each instance at time of apply.

### windows\_instance\_passwords

Description: A map of instance IDs to Windows passwords (if applicable).

### remote\_admin\_commands

Description: A map of instance IDs to command-line strings which can be used to connect to each instance.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ec2/outputs.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ec2/main.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/ec2/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
