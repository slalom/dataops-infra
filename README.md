# `dataops-infra` - Infrastructure Catalog for Slalom DataOps

## Instructions

### Workstation Setup

1. Follow the steps in [Windows Development Quickstart](https://docs.dataops.tk/docs/windows_development.html) or [Mac Development Quistart](https://docs.dataops.tk/docs/mac_development.html), which will automatically install all of the following required tools: Terraform, Docker, VS Code, Python 3, and Git.
2. Clone this repo to your local machine.

### Install Infrastructure from the Infrastructure Catalog

The below instructions will use `tableau-on-aws` as the example. The same steps can be repeated for any Infrastructure Catalog items within 'samples' folder.

```bash
cd samples/tableau-on-aws
terraform init
terraform apply
```

## Catalog Documentation

Catalog documentation for all supported components is available from the [Infrastructure Catalog Index](docs/catalog_index.md).

## Contributions Guide

For information on how to contribute in the form of PRs or Issues, please see [CONTRIBUTING.md](docs/CONTRIBUTING.md).

## Related Code Repos

* [dataops-docs](https://github.com/slalom-ggp/dataops-docs): Documentation Resources
* [dataops-infra](https://github.com/slalom-ggp/dataops-infra): Infrastructure Catalog _(this code repo)_
* [dataops-tools](https://github.com/slalom-ggp/dataops-powertools): Python-based dataops tools (`pip install slalom.dataops`)
* [dataops-project-template](https://github.com/slalom-ggp/dataops-project-template): A sample dataops project. Clone and modify for your own project.

## Troubleshooting

For troubleshooting help, please see [Troubleshooting](docs/troubleshooting.md).
