# AWS Component Modules

These are technical component modules to be composed into specific use cases as defined by higher-level Catalog modules (`catalog/aws`).

## Input and Output Variables

Each AWS component module supports the following inputs:

| Direction | Variable Name     | Required | Description                                                                                                                                                         |
| :-------: | ----------------- | :------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  `input`  | `name_prefix`     |    Y     | Unless otherwise stated, this will be a concatenation like `{project_shortname}-` and will be used as a unique name prefix for resources created within the module. |
|  `input`  | `aws_region`      |    N     | The region where resources should be deployed. If blank, this defaults to the region specified at the project (provider) level.                                     |
|  `input`  | `resource_tags`   |    N     | Allows designer to add default tags to child modules. These should then be propagated to all child resources which support tagging.                                 |
|  `input`  | `vpc_id`          |    Y     | The VPC within which to create new resources.                                                                                                                       |
|  `input`  | `private_subnets` |    Y     | Resources which _**should not**_ have publicly-accessible IP addresses will be created here.                                                                        |
|  `input`  | `public_subnets`  |    Y     | Resources which _**should**_ have publicly-accessible IP addresses will be created here.                                                                            |
| `output`  | `summary`         |    Y     | A human-readable summary of the resources which were deployed, especially unique resource IDs and connection strings (if applicable).                               |

## VPCs and Subnets

Note: Component modules (unlike Catalog modules) _**will not**_ automatically create VPCs or Subnets. Therefore, all of the following required input variables are required: `vpc_id`, `public_subnets`, `private_subnets`.
