
# AWS RDS

`/components/aws/rds`

## Overview


Flag --no-sort has been deprecated, use '--sort=false' instead
Deploys an RDS-backed database. RDS currently supports the following database engines:
* Aurora
* MySQL
* PostgreSQL
* Oracle
* SQL Server

Each engine type has it's own required configuration. For already-configured database
configurations, see the catalog modules: `catalog/aws/mysql` and `catalog/aws/postgres`
which are built on top of this component module.

* NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

## Requirements

No requirements.

## Providers

The following providers are used by this module:

- http

- random

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

### admin\_username

Description: The initial admin username.

Type: `string`

### engine

Description: The type of database to launch. E.g.: `aurora`, `aurora-mysql`,`aurora-postgresql`,
`mariadb`,`mysql`,`oracle-ee`,`oracle-se2`,`oracle-se1`,`oracle-se`,`postgres`,
`sqlserver-ee`,`sqlserver-se`,`sqlserver-ex`,`sqlserver-web`.
Check RDS documentation for updates to the supported list, and for details on each engine type.

Type: `string`

### engine\_version

Description: When paired with `engine`, specifies the version of the database engine to deploy.

Type: `string`

### jdbc\_port

Description: Optional. Overrides the default JDBC port for incoming SQL connections.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### admin\_password

Description: The initial admin password. Must be 8 characters long.

Type: `string`

Default: `null`

### identifier

Description: The endpoint id which will be used within connection strings and URLs.

Type: `string`

Default: `"rds-db"`

### database\_name

Description: The name of the initial database to be created.

Type: `string`

Default: `"default_db"`

### instance\_class

Description: Enter the desired node type. The default and cheapest option is 'db.t2.micro' @ ~$0.017/hr, or ~$120/mo (https://aws.amazon.com/rds/mysql/pricing/ )

Type: `string`

Default: `"db.t2.micro"`

### kms\_key\_id

Description: Optional. The ARN for the KMS encryption key used in cluster encryption.

Type: `string`

Default: `null`

### skip\_final\_snapshot

Description: If true, will allow terraform to destroy the RDS cluster without performing a final backup.

Type: `bool`

Default: `false`

### storage\_size\_in\_gb

Description: The allocated storage value is denoted in GB

Type: `string`

Default: `"20"`

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

Description: The connection endpoint for the new RDS instance.

### summary

Description: Summary of resources created by this module.

---------------------

## Source Files

_Source code for this module is available using the links below._

* [outputs.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/rds/outputs.tf)
* [main.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/rds/main.tf)
* [variables.tf](https://github.com/slalom-ggp/dataops-infra/tree/main//components/aws/rds/variables.tf)

---------------------

_**NOTE:** This documentation was auto-generated using
`terraform-docs` and `s-infra` from `slalom.dataops`.
Please do not attempt to manually update this file._
