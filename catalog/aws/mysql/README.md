
# AWS MySQL

`/catalog/aws/mysql`

## Overview


Deploys a MySQL server running on RDS.

* NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

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

### admin\_username

Description: The initial admin username.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### admin\_password

Description: The initial admin password. Must be 8 characters long.

Type: `string`

Default: `null`

### database\_name

Description: The name of the initial database to be created.

Type: `string`

Default: `"default_db"`

### identifier

Description: The database name which will be used within connection strings and URLs.

Type: `string`

Default: `"rds-db"`

### instance\_class

Description: Enter the desired node type. The default and cheapest option is 'db.t2.micro' @ ~$0.017/hr, or ~$120/mo (https://aws.amazon.com/rds/mysql/pricing/ )

Type: `string`

Default: `"db.t2.micro"`

### jdbc\_port

Description: Optional. Overrides the default JDBC port for incoming SQL connections.

Type: `number`

Default: `3306`

### kms\_key\_id

Description: Optional. The ARN for the KMS encryption key used in cluster encryption.

Type: `string`

Default: `null`

### mysql\_version

Description: Optional. The specific MySQL version to use.

Type: `string`

Default: `"5.7.26"`

### storage\_size\_in\_gb

Description: The allocated storage value is denoted in GB.

Type: `string`

Default: `"20"`

### skip\_final\_snapshot

Description: If true, will allow terraform to destroy the RDS cluster without performing a final backup.

Type: `bool`

Default: `false`

### jdbc\_cidr

Description: List of CIDR blocks which should be allowed to connect to the instance on the JDBC port.

Type: `list(string)`

Default: `[]`

### whitelist\_terraform\_ip

Description: True to allow the terraform user to connect to the DB instance.

Type: `bool`

Default: `true`

## Outputs

The following outputs are exported:

### endpoint

Description: The MySQL connection endpoint for the new server.

### summary

Description: Summary of resources created by this module.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/mysql/main.tf)
* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/mysql/outputs.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//catalog/aws/mysql/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
