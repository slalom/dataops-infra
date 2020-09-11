---
nav_exclude: true
---
# [Slalom Infrastructure Catalog](../README.md) > Testing

## Terraform  Validation Testing and Linting

Terraform linting (aka `terraform fmt`) and `terraform validate` are executed
automatically in the CI/CD pipeline.

## Testing with the Terraform-Compliance Tool

1. Install the `terraform-compliance` tool:

    ```cmd
    pip install terraform-compliance
    ```

2. Deploy one of the samples:

    ```cmd
    cd samples/airflow-on-aws
    ```

3. Create the Terraform Plan file:

    ```cmd
    cd samples/airflow-on-aws
    terraform plan -out plan.out
    ```

4. Validate against a saved state file:

    ```cmd
    cd samples/airflow-on-aws
    terraform-compliance -p plan.out -f ..\..\tests\rules
    ```
