# AWS Catalog Modules

Catalog modules meet some specific functional needand are composed of lower-level component modules (`components/aws`).

## Input and Output Variables

Each AWS catalog module supports the following inputs:

| Direction | Variable Name   | Required | Description                                                                                                                                                         |
| --------- | --------------- | :------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `input`   | `name_prefix`   |    Y     | Unless otherwise stated, this will be a concatenation like `{project_shortname}-` and will be used as a unique name prefix for resources created within the module. |
| `input`   | `aws_region`    |    N     | The region where resources should be deployed. If blank, this defaults to the region specified at the project (provider) level.                                     |
| `input`   | `resource_tags` |    N     | Allows designer to add default tags to child modules. These should then be propagated to all child resources which support tagging.                                 |
| `output`  | `summary`       |    Y     | A human-readable summary of the resources which were deployed, especially unique resource IDs and connection strings (if applicable).                               |

## VPCs and Subnets

In general, catalog modules _**will**_ automatically create VPCs and Subnets as needed. If you prefer to use an existing subnet, or a subnet created by another module, please pass the following (optional) input variables.

| Variable Name     | Description                                                                                  |
| ----------------- | -------------------------------------------------------------------------------------------- |
| `vpc_id`          | The VPC within which to create new resources.                                                |
| `private_subnets` | Resources which _**should not**_ have publicly-accessible IP addresses will be created here. |
| `public_subnets`  | Resources which _**should**_ have publicly-accessible IP addresses will be created here.     |
