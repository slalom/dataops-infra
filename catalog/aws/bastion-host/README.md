---
parent: Infrastructure Catalog
title: AWS Bastion-Host
nav_exclude: false
---
# AWS Bastion-Host

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/aws/bastion-host?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/catalog/aws/bastion-host)

## Overview


The `bastion-host` module deploys an ECS-backed container which can be used to remotely test
or develop using the native cloud environment.

Applicable use cases include:

- Debugging network firewall and routing rules
- Debugging components which can only be run from whitelisted IP ranges
- Offloading heavy processing from the developer's local laptop
- Mitigating network reliability issues when working from WiFi or home networks

## Requirements

No requirements.

## Providers

No provider.

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

### aws\_credentials\_file

Description: Path to the AWS credentials file, used to ensure that the correct credentials are used during upload of the ECR image.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### standard\_image

Description: Optional. The name of an available prebuilt bastion image to use for the container.

- Currently only `dataopstk/bastion:python-3.8` is supported (default).
- Ignored if `custom_base_image` is provided.

Type: `string`

Default: `"dataopstk/bastion:python-3.8"`

### custom\_base\_image

Description: Optional. The name of a custom base image, on top of which to build a custom bastion image.

- Overrides any setting provided for `standard_image`.
- This option has additional workstation requirements, including Golang, Docker, and special docker
  config as defined here: https://infra.dataops.tk/components/aws/ecr-image/#prereqs

Type: `string`

Default: `null`

### settings

Description: Map of environment variables.

Type: `map(string)`

Default: `{}`

### secrets

Description: Map of environment secrets.

Type: `map(string)`

Default: `{}`

### container\_entrypoint

Description: Optional. Override the docker image's entrypoint.

Type: `any`

Default: `null`

### container\_num\_cores

Description: Optional. Specify the number of cores to use in the container.

Type: `number`

Default: `0.5`

### container\_ram\_gb

Description: Optional. Specify the amount of RAM to be available to the container.

Type: `number`

Default: `1`

### use\_private\_subnet

Description: If True, tasks will use a private subnet and will require a NAT gateway to pull the docker
image, and for any outbound traffic. If False, tasks will use a public subnet and will
not require a NAT gateway.

Type: `bool`

Default: `false`

### ssh\_public\_key\_filepath

Description: Optional. Path to a valid public key for SSH connectivity.

Type: `string`

Default: `null`

### ssh\_private\_key\_filepath

Description: Optional. Path to a valid public key for SSH connectivity.

Type: `string`

Default: `null`

### admin\_cidr

Description: List of source IP CIDR blocks which should be allowed to connect to the bastion host.

Type: `list(string)`

Default: `null`

## Outputs

The following outputs are exported:

### summary

Description: Summary of resources created by this module.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/bastion-host/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/bastion-host/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/bastion-host/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
