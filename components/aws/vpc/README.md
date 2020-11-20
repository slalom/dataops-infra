---
parent: Infrastructure Components
title: AWS VPC
nav_exclude: false
---
# AWS VPC

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/vpc?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/vpc)

## Overview


The VPC module creates a number of network services which support other key AWS functions.

Included automatically when creating this module:
* 1 VPC which contains the following:
    * 2 private subnets (for resources which **do not** need a public IP address)
    * 2 public subnets (for resources which do need a public IP address)
    * 1 NAT gateway (allows private subnet resources to reach the outside world)
    * 1 Intenet gateway (allows resources in public and private subnets to reach the internet)
    * route tables and routes to connect all of the above

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- http

- aws.region\_lookup

- aws

## Required Inputs

The following input variables are required:

### name\_prefix

Description: Standard `name_prefix` module input. (Prefix counts towards 64-character max length for certain resource types.)

Type: `string`

### resource\_tags

Description: Standard `resource_tags` module input.

Type: `map(string)`

### aws\_region

Description: Required. Specifies the AWS region.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### environment

Description: Standard `environment` module input. (Ignored for the `vpc` module.)

Type:

```hcl
object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
```

Default: `null`

### disabled

Description: As a workaround for unsupported 'count' feature in terraform modules, this switch can be used to disable the module entirely.

Type: `bool`

Default: `false`

### aws\_credentials\_file

Description: Optional, unless set at the main AWS provider level in which case it is required.

Type: `string`

Default: `null`

### aws\_profile

Description: Optional, unless set at the main AWS provider level in which case it is required.

Type: `string`

Default: `null`

### vpc\_cidr

Description: Optional. The CIDR block to use for the VPC network.

Type: `string`

Default: `"10.0.0.0/16"`

### subnet\_cidrs

Description: Optional. The CIDR blocks to use for the subnets.
The list should have the 2 public subnet cidrs first, followed by the 2 private subnet cidrs.
If omitted, the VPC CIDR block will be split evenly into 4 equally-sized subnets.

Type: `list(string)`

Default: `null`

### enable\_internet\_gateway

Description: Optional. Specifies if an Internet Gateway should be associated to the VPC. An Internet Gateway is required to receive
any type of incoming traffic over the internet.

Note:

- Most modules also supportthe variables `admin_cidr` (associated with `admin_ports`)
  and `app_cidr` (associated with `app_ports`).
- The `admin_cidr` and `app_cidr` variables can be leveraged to limit internet traffic only
  from specific sources.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### vpc\_id

Description: The unique ID of the VPC.

### private\_subnets

Description: The list of private subnets.

### public\_subnets

Description: The list of public subnets.

### public\_route\_table

Description: The ID of the route table for public subnets.

### private\_route\_table

Description: The ID of the route table for private subnets.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/vpc/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/vpc/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/vpc/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
