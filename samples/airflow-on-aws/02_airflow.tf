module "airflow" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/airflow-on-aws?ref=master"
  source        = "../../catalog/aws/airflow"
  name_prefix   = local.name_prefix
  resource_tags = local.project_tags

  # CONFIGURE HERE:

  container_image = "slalomggp/dataops:test-project-latest-dev"
  environment_vars = {
    "DETECT_HOSTNAME" = "true"
    "PROJECT_GIT_URL" = "git+https://github.com/slalom-ggp/dataops-infra.git"
  }
  environment_secrets = {
  }

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  admin_password    = "asdfAS12"
  aws_region        = local.aws_region

  */
}

output "summary" { value = module.airflow.summary }
