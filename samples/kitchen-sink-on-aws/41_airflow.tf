output "airflow_summary" { value = module.airflow.summary }
module "airflow" {
  source = "../../catalog/aws/airflow"
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/airflow?ref=main"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  container_image   = "puckel/docker-airflow"
  container_command = "webserver"
  environment_vars = {
    "PROJECT_GIT_URL" = "git+https://github.com/slalom-ggp/dataops-infra.git"
  }
  environment_secrets = {
  }

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  admin_password    = "asdf1234"
  aws_region        = local.aws_region

  */
}
