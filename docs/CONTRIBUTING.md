---
title: Contributing
has_children: false
nav_order: 4
nav_exclude: false
---
# Contributing Guide

1. [Feature Requests](#feature-requests)
2. [Bug Reports](#bug-reports)
3. [Pull Requests](#pull-requests)
4. [3-Tiered Design Pattern](#3-tiered-design-pattern)
   1. [Solution Modules or Sample Modules (Layer 1)](#solution-modules-or-sample-modules-layer-1)
   2. [Catalog Modules (Layer 2)](#catalog-modules-layer-2)
   3. [Component Modules (Layer 3)](#component-modules-layer-3)
5. [Coding Standards](#coding-standards)
   1. [Common Input and Output Variables](#common-input-and-output-variables)
   2. [Show Usage in Samples](#show-usage-in-samples)
   3. [Adhere to Formatting Standards](#adhere-to-formatting-standards)
   4. [Create Self-documenting Modules](#create-self-documenting-modules)
   5. [Follow Purpose-Driven Design Patterns](#follow-purpose-driven-design-patterns)

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

## 3-Tiered Design Pattern

When making changes to the terraform modules, please observe the following 3-tiered design pattern from targeted and business-focused (layer 1) to increasingly technical and generic (layer 3).

### Solution Modules or Sample Modules (Layer 1)

> _Solution modules should be configurable as simply as possible to align with the stated business requirements of the module._

### Catalog Modules (Layer 2)

> _**Catalog Modules (Layer 2)** should combine modules from Layer 3 in a method targeted to specific functional or business requirements._

### Component Modules (Layer 3)

> _**Component Modules (Layer 3)** define the technical solutions as mapped to individual cloud product offerings (EC2, EC2, Azure Functions, etc.), meeting a technical requirement from one or more catalog modules which reference them._

## Coding Standards

Submitted PRs should meet the following code standards before being merged into `master`:

### Common Input and Output Variables

In addition to custom variables, each AWS catalog and component module should support the following standard input and output variables:

| Direction | Variable Name   | Required | Description                                                                                                                                                         |
| :-------: | --------------- | :------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  `input`  | `name_prefix`   |    Y     | Unless otherwise stated, this will be a concatenation like `{project_shortname}-` and will be used as a unique name prefix for resources created within the module. |
|  `input`  | `environment`   |    N     | An object or map with values for `vpc_id`, `aws_region`, `public_subnets` and `private_subnets`, generally passed from the `aws/catalog/environment` module.        |
|  `input`  | `resource_tags` |    N     | Allows designer to add default tags to child modules. These should then be propagated to all child resources which support tagging.                                 |
| `output`  | `summary`       |    Y     | A human-readable summary of the resources which were deployed, especially unique resource IDs and connection strings (if applicable).                               |

### Show Usage in Samples

* As a rule, each component and category module should be referenced by at least one solution module in the `samples` folder, and the sample should demonstrate how to utilize the core functionality.

  * In addition to providing an easy on-ramp for new users to learn how to use your module, your sample module is also an entrypoint for the CI/CD pipeline to perform automated tests.
  * If your sample code ever stops working, the automated tests will catch this, giving us a means to catch and fix the breakages before they can impact users.

### Adhere to Formatting Standards

* Terraform makes it very easy way to auto-format modules, which in turn ensures a consistent experience when reviewing code across multiple authors.

  * If you use VS Code, the defaults specified in `settings.json` should automatically apply formatting on each file save.
  * Formatting is checked automatically after each commit by the CI/CD pipeline.
  * If you receive failures related to Terraform formatting, simply run `terraform fmt -recursive` from the root of the repo. This command will auto format the entire repo and then you can simply commit the resulting changes.

### Create Self-documenting Modules

* In order for components to be effectively used by a broad audience, each module must be self-documenting and should be included in the Catalog auto-document tool.
  * Make sure each input and output variable has it's `description` field set.
  * Make sure each module has a `main.tf` file and that the file contains a header comment with a paragraph description of the basic module functions. See [components/aws/secrets-manager/main.tf](../components/aws/secrets-manager/main.tf) for a sample.
  * All input variables should be stored in `variables.tf` and all output variables should be stored in `outputs.tf`.
  * After the above are met, update the project docs by navigating to the `docs` directory and running `build.py` (more details [here](../autodocs/README.md)). This command will update all module README files as well as [catalog/README.md](../catalog/README.md) and [components/README.md](../components/README.md).

### Follow Purpose-Driven Design Patterns

**Modules should be written as simply as possible, but no simpler.**

* There is no expectation that modules should be fully generic or meet every use case.
* Opinionated and purpose-driven approaches are preferred versus trying to build modules that are one-size-fits-all.

## Preventing Security Leaks

Please read the [Secrets Guide](./secrets.md) for instructions on how to properly manage secrets
and prevent accidentally compromising sensitive information.
