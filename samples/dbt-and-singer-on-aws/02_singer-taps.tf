module "singer_taps_on_aws" {

  # BOILERPLATE HEADER (NO NEED TO CHANGE):

  source        = "../../catalog/aws/singer-taps"
  name_prefix   = local.name_prefix
  resource_tags = local.project_tags

  # ADD OR MODIFY CONFIGURATION HERE:

  container_image            = "slalomggp/dataops:test-project-latest-dev"
  sync_command               = "./gradlew tapSyncSalesforce"
  scheduled_refresh_interval = "4 hours"
  environment_vars           = {}

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  docker_registry_url        = ""
  docker_user                = ""
  docker_password            = ""
  scheduled_refresh_interval = "1 minute"
  scheduled_timezone         = "PST"
  scheduled_refresh_times    = ["0300", "1200", "1800"]

  */
}

# BOILERPLATE OUTPUT (NO NEED TO CHANGE):
output "singer_summary" { value = module.singer_taps_on_aws.summary }
