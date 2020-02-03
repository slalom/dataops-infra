# Contributing Guide

1. [Feature Requests](#feature-requests)
2. [Bug Reports](#bug-reports)
3. [Pull Requests](#pull-requests)
   1. [Guide to Creating a Pull Request](#guide-to-creating-a-pull-request)
   2. [Guide to Creating Terraform Modules](#guide-to-creating-terraform-modules)

## Feature Requests

Feature Requests for DataOps projects are tracked as issues and are organized into a backlog here: [docs.dataops.tk/backlog](https://docs.dataops.tk/backlog)

## Bug Reports

Bug Reports are tracked as issues in this repo. To create a bug report, please log a new Issue.

## Pull Requests

Pull Requests (PRs) are the method used for contributions of new code.

### Guide to Creating a Pull Request

1. Start by creating a personal fork of this repo.
2. Create a new branch from 'master' and commit your changes.
3. Create a new Pull Request to this repo (not your personal) which references your new branch.
4. The maintainers will reply to your PR, generally within 3 business days, and may ask questions or suggest changes.
5. After all outstanding reviews have passed, your code will be merged by the maintainers into the master branch, which is essentially "production".

### Guide to Creating Terraform Modules

When making changes to the terraform modules, please observe the following design patterns.

#### Solution/Sample Modules (Layer 1)

> _Solution modules should be configurable as simply as possible to align with the stated business requirements of the module._

| Direction | Variable Name   | Required  | Description |
| --------  | --------------- | --------- | ----------- |
| `input`   | `project_shortname` | Y     | Should be in CamelCase and cannot have special characters. This will be used as a unique name prefix for resources created by the module. |
| `input`   | `cloud_region`  | Y         | For AWS modules, this will be used as `aws_region`. For Azure modules, this will be used as `location`. |
| `input`   | `resource_tags` | N         | Allows user to add default tags to child modules. These should then be propagated to all child resources which support tagging. |
| `output`  | `summary`       | A human-readable summary of the resources which were deployed, especially unique resource IDs and connection strings (if applicable). |

#### Catalog and Technical Modules (Layers 2 and 3)

> _**Catalog Modules (Layer 2)** should combine modules from Layer 3 in a method targeted to specific functional or business requirements._

> _**Technical Modules (Layer 3)** should meet some need from one or more catalog module. They do not need to meet every use case, but they should meet the catalog use cases in a way that is configurable and potentially reusable._

| Direction | Variable Name    | Required  | Description |
| --------  | ---------------- | :-------: | ----------- |
| `input`   | `name_prefix`    | Y         | Unless otherwise stated, this will be a concatenation like `{project_shortname}-` and will be used as a unique name prefix for resources created by the module. |
| `input`   | `aws_region`     | N         | (Does not apply to Azure.) For AWS modules, this specifies the region where resources should be deployed. If left blank, this will default to the region specified at the project (provider) level. |
| `input`   | `resource_group` | Y (Azure) | (Does not apply to AWS.) For Azure modules, this specifies which resource group to use for newly created resources, which also determines the Azure region. |
| `input`   | `resource_tags`  | N         | Allows designer to add default tags to child modules. These should then be propagated to all child resources which support tagging. |
| `output`  | `summary`        | Y         | A human-readable summary of the resources which were deployed, especially unique resource IDs and connection strings (if applicable). |

**Notes:**

* These are only the current best practices, but this document like everything else in this repo is subject to code review and improvements. Feel free to suggest changes.
