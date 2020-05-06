# Infrastructure Catalog for Slalom DataOps

## Catalog Documentation

Catalog documentation is available from the [Infrastructure Catalog Index](catalog/README.md).

## Contributions Guide

For information on how to request enhancements, submit bug reports, or contribute code, please see the [Contributing Guide](docs/CONTRIBUTING.md).

## User Guide

### Workstation Setup

1. Follow the steps in [Windows Development QuickStart](https://docs.dataops.tk/setup/windows.html) or [Mac Development Quistart](https://docs.dataops.tk/setup/mac.html), which will automatically install all of the following required tools: Terraform, Docker, VS Code, Python 3, and Git.
2. Clone this repo to your local machine.

### Deploying from the Infrastructure Catalog

The below instructions will use `tableau-on-aws` as the example. The same steps can be repeated for any Infrastructure Catalog items within 'samples' folder.

```bash
cd samples/tableau-on-aws
terraform init
terraform apply
```

## Related Code Repos

* [dataops-infra](https://github.com/slalom-ggp/dataops-infra): Infrastructure Catalog _(this code repo)_
* [dataops-docs](https://github.com/slalom-ggp/dataops-docs): Other documentation and resources resources for DataOps projects
* [dataops-tools](https://github.com/slalom-ggp/dataops-powertools): Python-based dataops tools (`pip install slalom.dataops`)
* [dataops-project-template](https://github.com/slalom-ggp/dataops-project-template): A sample dataops project. Clone and modify to launch your own project.

## Troubleshooting

For troubleshooting help, please see [Troubleshooting](docs/troubleshooting.md).
