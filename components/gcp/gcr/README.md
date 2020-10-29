---
parent: Infrastructure Components
title: AWS ECR
nav_exclude: false
---
# AWS GCR

[`source = "git::https://github.com/slalom-ggp/dataops-infra/tree/main/components/gcp/gcr?ref=main"`](https://github.com/slalom-ggp/dataops-infra/tree/main/components/aws/ecr)

## Overview


GCR (Google Container Registry) is the private-hosted AWS equivalent of DockerHub. GCR allows you to securely publish docker images which
should not be accessible to external users.

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- gcp

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

### repository\_name

Description: Required. A name for the ECR respository. (Will be concatenated with `image_name`.)

Type: `string`

### image\_name

Description: Required. The default name for the docker image. (Will be concatenated with `repository_name`.)

Type: `string`

## Optional Inputs

No optional input.

## Outputs

The following outputs are exported:

### gcr\_repo\_arn

Description: The unique ID (ARN) of the ECR repo.

### gcr\_repo\_root

Description: The path to the ECR repo, excluding image name.

### gcr\_image\_url

Description: The full path to the ECR image, including image name.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/gcp/gcr/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/gcp/gcr/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/gcp/gct/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
