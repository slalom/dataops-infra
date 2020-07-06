
# AWS Tableau-Server

`/catalog/aws/tableau-server`

## Overview


This module securely deploys one or more Tableau Servers, which can then be used to host reports in production or POC environments.
The module supports both Linux and Windows versions of the Tableau Server Software.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- aws

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

## Optional Inputs

The following input variables are optional (have default values):

### admin\_cidr

Description: Optional. The IP address range(s) which should have access to the admin
on the Tableau Server instances. By default this will default to only allow
connections from the terraform user's current IP address.

Type: `list`

Default: `[]`

### app\_cidr

Description: Optional. The IP address range(s) which should have access to the view the
Tableau Server web instance (excluding the TMS admin portal and other admin
ports). If not set, this will default to allow incoming connections from
any IP address (['0.0.0.0/0']). In general, this should be omitted unless the
site has a VPN or other internal list of IP whitelist ranges.

Type: `list`

Default:

```json
[
  "0.0.0.0/0"
]
```

### ec2\_instance\_type

Description: Optional. Overrides the Tableau Server instance type.

Type: `string`

Default: `"m5.4xlarge"`

### ec2\_instance\_storage\_gb

Description: The amount of storage to provision on each instance, in GB.

Type: `number`

Default: `100`

### linux\_use\_https

Description: True if the Linux instances should use HTTPS.

Type: `bool`

Default: `false`

### linux\_https\_domain

Description: The https domain if the Linux instances should use HTTPS.

Type: `string`

Default: `""`

### num\_linux\_instances

Description: The number of Tableau Server instances to create on Linux.

Type: `number`

Default: `1`

### num\_windows\_instances

Description: The number of Tableau Server instances to create on Windows.

Type: `number`

Default: `0`

### registration\_file

Description: A path to a local or remote file for Tableau registration.

Type: `string`

Default: `"../../.secrets/registration.json"`

### windows\_use\_https

Description: True if the Windows instances should use HTTPS.

Type: `bool`

Default: `false`

### windows\_https\_domain

Description: The https domain if the Windows instances should use HTTPS.

Type: `string`

Default: `""`

### ssh\_keypair\_name

Description: Optional. Name of SSH Keypair in AWS.

Type: `string`

Default: `null`

### ssh\_private\_key\_filepath

Description: Optional. Path to a valid public key for SSH connectivity.

Type: `string`

Default: `null`

### version\_string

Description: Determines which version of Tableau will be installed during setup. For a list of
available options, browse to the bublic S3 bucket: `tableau-quickstart`

Example: `2020-1-0`.

Type: `string`

Default: `"2020-1-0"`

### download\_source

Description: Optional. Overrides the default file download path. You may optionally also use `{version_string}`
as a placeholder for the version string input variable.

Examples:
 - `https://tableau-quickstart.s3.amazonaws.com/tableau-server-{version_string}_amd64.deb`
 - `s3://tableau-quickstart/tableau-server-{version_string}_amd64.deb`

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### ec2\_instance\_ids

Description: The EC2 intance ID(s) created by the module.

### ec2\_instance\_private\_ips

Description: The private IP address for each EC2 instance.

### ec2\_instance\_public\_ips

Description: The public IP address for each EC2 instance (if applicable).

### ec2\_instance\_states

Description: The current EC2 instance status for each Tableau Server instance, as of time of plan execution.

### ec2\_remote\_admin\_commands

Description: Command line command to connect to the Tableau Server instance(s) via RDP or SSH.

### ec2\_windows\_instance\_passwords

Description: The admin passwords for Windows instances (if applicable).

### ssh\_private\_key\_filepath

Description: Local path to private key file for connecting to the server via SSH.

### summary

Description: Summary of resources created by this module.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/tableau-server/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/tableau-server/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/tableau-server/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
