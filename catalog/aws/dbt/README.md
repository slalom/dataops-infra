
# AWS DBT

`/catalog/aws/dbt`

## Overview


DBT (Data Built Tool) is a CI/CD and DevOps-friendly platform for automating data transformations. More info at [www.getdbt.com](https://www.getdbt.com).

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

Description: Optional. The range of IP addresses which should be able to access the DBT instance. Defaults to the local user's current IP.

Type: `list`

Default: `[]`

### container\_image

Description: Optional. A docker image to override the default image.

Type: `string`

Default: `"slalomggp/dataops"`

### container\_entrypoint

Description: Optional. Overrides the docker image entrypoint.

Type: `any`

Default: `null`

### container\_num\_cores

Description: Optional. Overrides the number of CPU cores used.

Type: `number`

Default: `4`

### container\_ram\_gb

Description: Optional. Overrides the RAM used (in GB).

Type: `number`

Default: `16`

### dbt\_project\_git\_repo

Description: Optional. A git repo to download to the local image which contains DBT transforms information.

Type: `string`

Default: `"git+https://github.com/slalom-ggp/dataops-project-template.git"`

### dbt\_run\_command

Description: Optional. The default command to run when executing DBT.

Type: `string`

Default: `null`

### environment\_secrets

Description: Mapping of environment variable names to secret manager ARNs.
e.g. arn:aws:secretsmanager:[aws\_region]:[aws\_account]:secret:prod/ECSRunner/AWS\_SECRET\_ACCESS\_KEY

Type: `map(string)`

Default: `{}`

### environment\_vars

Description: Mapping of environment variable names to their values.

Type: `map(string)`

Default: `{}`

### scheduled\_refresh\_interval

Description: A rate string, e.g. '5 minutes'. This is in addition to any other scheduled executions.

Type: `string`

Default: `null`

### scheduled\_refresh\_times

Description: A list of schedule strings in 6-part cron notation. For help creating cron schedule codes: https://crontab.guru

Type: `list(string)`

Default: `[]`

### scheduled\_timezone

Description: The timezone code with which to evaluate execution schedule(s).

Type: `string`

Default: `"PT"`

## Outputs

The following outputs are exported:

### summary

Description: Summary of resources created by this module.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/dbt/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/dbt/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/dbt/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
