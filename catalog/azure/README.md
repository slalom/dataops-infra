# Azure Catalog Modules

Catalog modules meet some specific functional needand are composed of lower-level component modules (`components/azure`).

## Input and Output Variables

Each Azure catalog module supports the following inputs:

| Direction | Variable Name    | Required | Description                                                                                                                                                         |
| --------- | ---------------- | :------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `input`   | `name_prefix`    |    Y     | Unless otherwise stated, this will be a concatenation like `{project_shortname}-` and will be used as a unique name prefix for resources created within the module. |
| `input`   | `resource_group` |    Y     | The resource group to use for newly created resources, which also determines the Azure region.                                                                      |
| `input`   | `resource_tags`  |    N     | Allows designer to add default tags to child modules. These should then be propagated to all child resources which support tagging.                                 |
| `output`  | `summary`        |    Y     | A human-readable summary of the resources which were deployed, especially unique resource IDs and connection strings (if applicable).                               |
