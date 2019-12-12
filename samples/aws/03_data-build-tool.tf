module "dbt_on_aws" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source      = "../../catalog/dbt-on-aws"
  name_prefix = local.name_prefix
  aws_region  = local.aws_region

  # ADD OR MODIFY CONFIGURATION HERE:

  docker_image = "slalom/dataops"
  docker_tags = {
    "beta" = "latest-dev"
    "prod" = "latest"
  }

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  weekday_refresh_times     = "0300,1000,1700" # 3AM, 10AM, 5PM
  weekend_refresh_times     = "0300"
  schedule_timezone         = "PT"
  docker_registry_url       = ""
  docker_user               = ""
  docker_password           = ""

  */
}

# BOILERPLATE OUTPUT (NO NEED TO CHANGE):
output "summary" { value = module.dbt_on_aws.summary }
