
# AWS Glue-Crawler

`/components/aws/glue-crawler`

## Overview


Flag --no-sort has been deprecated, use '--sort=false' instead
Glue is AWS's fully managed extract, transform, and load (ETL) service.
A Glue crawler is used to access a data store and create table definitions.
This can be used in conjuction with Amazon Athena to query flat files in S3 buckets using SQL.

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

### glue\_database\_name

Description: Name of the Glue catalog database.

Type: `string`

### glue\_crawler\_name

Description: Name of the Glue crawler.

Type: `string`

### s3\_target\_bucket\_name

Description: S3 target bucket for Glue crawler.

Type: `string`

### target\_path

Description: Path to crawler target file(s).

Type: `string`

## Optional Inputs

No optional input.

## Outputs

The following outputs are exported:

### glue\_crawler\_name

Description: The name of the Glue crawler.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/glue-crawler/outputs.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/glue-crawler/main.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/glue-crawler/variables.tf)
* [iam.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/glue-crawler/iam.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
