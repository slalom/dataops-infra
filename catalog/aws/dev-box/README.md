
# AWS Dev-Box

`/catalog/aws/dev-box`

## Overview


The `dev-box` catalog module deploys an ECS-backed container which can be used to remotely test
or develop using the native cloud environment. Applicable use cases include:

* Debugging network firewall and routing rules
* Debugging components which can only be run from whitelisted IP ranges
* Offloading heavy processing from the developer's local laptop
* Mitigating network relability issues when working from WiFi or home networks

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| aws\_credentials\_file | Path to the AWS credentials file, used to ensure that the correct credentials are used during upload of the ECR image. | `string` | n/a | yes |
| container\_entrypoint | Optional. Override the docker image's entrypoint. | `any` | n/a | yes |
| environment | Standard `environment` module input. | <pre>object({<br>    vpc_id          = string<br>    aws_region      = string<br>    public_subnets  = list(string)<br>    private_subnets = list(string)<br>  })</pre> | n/a | yes |
| name\_prefix | Standard `name_prefix` module input. | `string` | n/a | yes |
| resource\_tags | Standard `resource_tags` module input. | `map(string)` | n/a | yes |
| source\_image | Required. The docker image to execute in the container (e.g. 'ubuntu:18.04'). | `string` | n/a | yes |
| ssh\_private\_key\_filepath | Optional. Path to a valid public key for SSH connectivity. | `string` | n/a | yes |
| ssh\_public\_key\_filepath | Optional. Path to a valid public key for SSH connectivity. | `string` | n/a | yes |
| container\_num\_cores | Optional. Specify the number of cores to use in the container. | `number` | `0.5` | no |
| container\_ram\_gb | Optional. Specify the amount of RAM to be available to the container. | `number` | `1` | no |
| secrets | Map of environment secrets. | `map(string)` | `{}` | no |
| settings | Map of environment variables. | `map(string)` | `{}` | no |
| use\_private\_subnet | If True, tasks will use a private subnet and will require a NAT gateway to pull the docker<br>image, and for any outbound traffic. If False, tasks will use a public subnet and will<br>not require a NAT gateway. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| summary | Summary of resources created by this module. |

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/dev-box/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/dev-box/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/master//catalog/aws/dev-box/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
