# Contributing Guide

1. [Feature Requests](#feature-requests)
2. [Bug Reports](#bug-reports)
3. [Pull Requests](#pull-requests)
4. [Contributing New Terraform Modules](#guide-to-creating-terraform-modules)
   1. [Solution/Sample Modules (Layer 1)](#solutionsample-modules-layer-1)
   2. [Catalog Modules (Layer 2)](#catalog-modules-layer-2)
   3. [Component Modules (Layer 3)](#component-modules-layer-3)
5. [Coding Standards](#coding-standards)
6. [General Design Principles](#general-design-principles)

## Feature Requests

_Feature Requests for DataOps projects are tracked as issues and are organized into a backlog here: [docs.dataops.tk/backlog](https://docs.dataops.tk/backlog)_

## Bug Reports

_Bug Reports are tracked as issues in this repo. To create a bug report, please log a new Issue._

## Pull Requests

_Pull Requests (PRs) are the method used for intaking new code contributions_

**Guide to Creating a Pull Request:**

1. Start by creating a personal fork of this repo.
2. Create a new branch from 'master' and commit your changes.
3. Create a new Pull Request to this repo (not your personal) which references your new branch.
4. The maintainers will reply to your PR, generally within 3 business days, and may ask questions or suggest changes.
5. After all outstanding reviews have passed, your code will be merged by the maintainers into the master branch, which is essentially "production".

## Guide to Creating Terraform Modules

When making changes to the terraform modules, please observe the following design patterns.

### Solution/Sample Modules (Layer 1)

> _Solution modules should be configurable as simply as possible to align with the stated business requirements of the module._

| Direction | Variable Name       | Required  | Description                                                                                                                               |
| :-------: | ------------------- | :-------: | ----------------------------------------------------------------------------------------------------------------------------------------- |
|  `input`  | `project_shortname` |     Y     | Should be in CamelCase and cannot have special characters. This will be used as a unique name prefix for resources created by the module. |
|  `input`  | `aws_region`        |  Y (AWS)  | The AWS region code.                                                                                                                      |
|  `input`  | `location`          | Y (Azure) | The Azure region code.                                                                                                                    |
|  `input`  | `resource_tags`     |     N     | Allows user to add default tags to child modules. These should then be propagated to all child resources which support tagging.           |
| `output`  | `summary`           |           | A human-readable summary of the resources which were deployed, especially unique resource IDs and connection strings (if applicable).     |

### Catalog Modules (Layer 2)

> _**Catalog Modules (Layer 2)** should combine modules from Layer 3 in a method targeted to specific functional or business requirements._

**Input and Output Variables for Catalog Modules:**

* **AWS Catalog modules** should match parameters and conventions specified here: [catalog/aws/README.md](/catalog/aws/README.md).
* **Azure Catalog modules** should match parameters and conventions specified here: [catalog/azure/README.md](/catalog/azure/README.md).

### Component Modules (Layer 3)

> _**Component Modules (Layer 3)** define the technical solutions as mapped to individual cloud product offerings (EC2, EC2, Azure Functions, etc.), meeting a technical requirement from one or more catalog modules which reference them._

**Input and Output Variables for Components Modules:**

* **AWS Components** should match parameters and conventions specified here: [components/aws/README.md](/components/aws/README.md).
* **Azure Components** should match parameters and conventions specified here: [components/azure/README.md](/components/azure/README.md).

### Coding Standards

Submitted PRs should meet the following code standards before being merged into `master`:

1. **Modules should have at least one sample** - As a rule, each component and category module should be referenced by at least one solution module in the `samples` folder, and the sample should demonstrate how to utilize the core functionality.
   * In addition to providing an easy on-ramp for new users to learn how to use your module, your sample module is also an entrypoint for the CI/CD pipeline to perform automated tests.
   * If your sample code ever stops working, the automated tests will catch this, giving us a means to catch and fix the breakages before they can impact users.
2. **Modules should match formatting standards**. Terraform makes it very easy way to auto-format modules, which in turn ensures a consistent experience when reviewing code across multiple authors.
   * If you use VS Code, the defaults specified in `settings.json` should automatically apply formatting on each file save.
   * Formatting is checked automatically after each commit by the CI/CD pipeline.
   * If you receive failures related to Terraform formatting, simply run `terraform fmt -recursive` from the root of the repo. This command will auto format the entire repo and then you can simply commit the resulting changes.
3. **Modules should be self-documenting** - In order for components to be effectively used by a broad audience, each module must be self-documenting and should be included in the Catalog auto-document tool.
   * Make sure each input and output variable has it's `description` field set.
   * Make sure each module has a `main.tf` file and that the file contains a header comment with a paragraph description of the basic module functions. See [components/aws/secrets-manager/main.tf](../components/aws/secrets-manager/main.tf) for a sample.
   * All input variables should be stored in `variables.tf` and all output variables should be stored in `outputs.tf`.
   * After the above are met, update the project docs by navigating to the `docs` directory and running `build.py`. This command will update all module README files as well as [catalog_index.md](catalog_index.md) and [components_index.md](components_index.md).

### General Design Principles

**Modules should be written as simply as possible, but no simpler.**

* There is no expectation that modules should be fully generic or meet every use case.
* Opinionated and purpose-driven approaches are preferred versus trying to build modules that are one-size-fits-all.

_(More to come...)_
