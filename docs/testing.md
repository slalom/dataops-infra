# [Slalom Infrastructure Catalog](../README.md) > Testing

## Terraform  Validation Testing and Linting

Terraform linting (aka `terraform fmt`) and `terraform validate` are executed
automatically in the CI/CD pipeline.

## Testing with the Terraform-Compliance Tool

1. Install the `terraform-compliance` tool:

    ```cmd
    pip install terraform-compliance
    ```

2. Deploy a sample:

   * _Using the `airflow-on-aws` sample, for example_:

        ```cmd
        cd samples/airflow-on-aws
        ```

3. Validate against a saved state file:

   * _After running `terraform apply`_

        ```cmd
        cd samples/airflow-on-aws
        terraform-compliance -p terraform.tfstate
        ```
