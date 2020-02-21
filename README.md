# `dataops-infra` - Infrastructure Catalog for Slalom DataOps

## Instructions

### Workstation Setup

1. Follow the steps in [Windows Development Quickstart](https://docs.dataops.tk/docs/windows_development.html), which will automatically install all of the following required tools: Terraform, Docker, VS Code, Python 3, and Git.
2. Clone this repo to your local machine.
3. Initialize your SSH key and local settings file.

    ```bash
    cd catalog/aws-prereqs
    terraform init
    terraform apply -auto-approve
    ```

   * _**Note:** If you receive an error that "Provider produced inconsistent final plan", please rerun the final `terraform apply` step with the same provided input values. This is a known issue and will be resolved in a future update._

### Install Infrastructure from the Infrasturcture Catalog

The below instructions will use 'tableau-server-on-aws' as the example. The same steps can be repeated for any Infrastructure Catalog items within 'catalog' folder.

```bash
cd catalog/tableau-server-on-aws
terraform init
terraform apply
```

## Debug Info

* **Note:** It is possible for environments to become stuck due to failures in printing output variables, for instance if SSH keys are accidentally deleted or rotated incorrectly. To ignore errors from outputs which cannot be parsed, first set the environment variable: `TF_WARN_OUTPUT_ERRORS=1` and then re-run `terraform apply` or `terrafom destroy`. This will warn on output errors instead of failing the process.

## Related Code Repos

* [dataops-docs](https://github.com/slalom-ggp/dataops-docs): Documentation Resources
* [dataops-infra](https://github.com/slalom-ggp/dataops-infra): Infrastructure Catalog _(this code repo)_
* [dataops-powertools](https://github.com/slalom-ggp/dataops-powertools): Python-based dataops tools (`pip install slalom.dataops`)
* [dataops-project-template](https://github.com/slalom-ggp/dataops-project-template): A sample dataops project. Clone and modify for your own project.
