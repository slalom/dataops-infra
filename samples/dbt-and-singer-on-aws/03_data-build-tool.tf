module "dbt_on_aws" {

  # BOILERPLATE HEADER (NO NEED TO CHANGE):

  # source        = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/dbt?ref=master"
  source        = "../../catalog/aws/dbt"
  name_prefix   = local.name_prefix
  resource_tags = local.resource_tags
  environment   = module.env.environment

  # ADD OR MODIFY CONFIGURATION HERE:

  container_image            = "slalomggp/dataops:test-project-latest-dev"
  dbt_run_command            = "./gradlew dbtSeed dbtCompile dbtRun"
  scheduled_timezone         = "PST"
  scheduled_refresh_interval = "4 hours"
  environment_vars = {
    "PROJECT_GIT_URL" = "git+https://github.com/slalom-ggp/dataops-infra.git"
    "WITH_SPARK"      = "true"
  }

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  docker_registry_url        = ""
  docker_user                = ""
  docker_password            = ""
  scheduled_refresh_interval = "1 minute"
  scheduled_refresh_times    = ["0300", "1200", "1800"]

  */
}

# BOILERPLATE OUTPUT (NO NEED TO CHANGE):
output "dbt_summary" { value = module.dbt_on_aws.summary }
