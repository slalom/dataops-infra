# Troubleshooting Guide

## Terraform output errors during destroy

* **Note:** It is possible for environments to become stuck due to failures in printing output variables, for instance if SSH keys are accidentally deleted or rotated incorrectly. To ignore errors from outputs which cannot be parsed, you can **temporarily** set the environment variable: `TF_WARN_OUTPUT_ERRORS=1` and then re-run `terraform apply` or `terrafom destroy`. This will ignore all output errors instead of failing the process (do not use unless needed).
