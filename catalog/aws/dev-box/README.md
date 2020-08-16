
# AWS Dev-Box

`/catalog/aws/dev-box`

## Overview


The `dev-box` catalog module deploys an ECS-backed container which can be used to remotely test
or develop using the native cloud environment. Applicable use cases include:

* Debugging network firewall and routing rules
* Debugging components which can only be run from whitelisted IP ranges
* Offloading heavy processing from the developer's local laptop
* Mitigating network relability issues when working from WiFi or home networks

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

### source\_image

Description: Required. The docker image to execute in the container (e.g. 'ubuntu:18.04').

Type: `string`

### aws\_credentials\_file

Description: Path to the AWS credentials file, used to ensure that the correct credentials are used during upload of the ECR image.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

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

## Outputs

The following outputs are exported:

### summary

Description: Summary of resources created by this module.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/dev-box/outputs.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/dev-box/main.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/dev-box/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
