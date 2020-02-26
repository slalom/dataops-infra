# AWS Component Modules

These are technical component modules to be composed into specific use cases as defined by higher-level Catalog modules (`catalog/aws`).

## Input and Output Variables

Each AWS component module supports the following inputs:

| Direction | Variable Name   | Required | Description                                                                                                                                                         |
| :-------: | --------------- | :------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  `input`  | `name_prefix`   |    Y     | Unless otherwise stated, this will be a concatenation like `{project_shortname}-` and will be used as a unique name prefix for resources created within the module. |
|  `input`  | `environment`   |    N     | An object or map with values for `vpc_id`, `aws_region`, `public_subnets` and `private_subnets`                                                                     |
|  `input`  | `resource_tags` |    N     | Allows designer to add default tags to child modules. These should then be propagated to all child resources which support tagging.                                 |
| `output`  | `summary`       |    Y     | A human-readable summary of the resources which were deployed, especially unique resource IDs and connection strings (if applicable).                               |

**The `environment` input variable generally is piped from `module.env.environment` and contains the following properties:**

| `vpc_id`          |    Y     | The VPC within which to create new resources.                                                                                                                       |
| `aws_region`      |    Y     | The AWS region code (e.g. 'us-east-2')                                                                            |
| `private_subnets` |    Y     | Resources which _**should not**_ have publicly-accessible IP addresses will be created here.                                                                        |
| `public_subnets`  |    Y     | Resources which _**should**_ have publicly-accessible IP addresses will be created here.                                                                            |
