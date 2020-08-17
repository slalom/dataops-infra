# Also defined in extract-to-s3:
# locals {
#   tap_metadata_path = "./taps"
#   tap_config_file   = "${local.tap_metadata_path}/.secrets/tap-covid-19-config.json"
# }

output "tap_to_rs_summary" { value = module.tap_to_rs.summary }
module "tap_to_rs" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "git::https://github.com/slalom-ggp/dataops-infra//catalog/aws/singer-taps?ref=main"
  name_prefix   = "${local.name_prefix}RSTap-"
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # ADD OR MODIFY CONFIGURATION HERE:

  scheduled_timezone = "PST"

  local_metadata_path     = local.tap_metadata_path
  data_lake_metadata_path = "s3://${module.data_lake.s3_metadata_bucket}"

  taps = [
    # Learn more and browse open source taps at: https://www.singer.io
    {
      id       = local.tap_id
      schedule = ["1000", "1400"]
      settings = {
        # How far back to backfill:
        start_date = "2019-01-01T00:00:00Z"
      }
      secrets = {
        # Maps the name of the needed secret to the file containing a key
        # under the same name:
        api_token  = local.tap_config_file,
        user_agent = local.tap_config_file,
      }
    }
  ]

  # data_lake_type         = "S3"
  # data_lake_storage_path = "s3://${module.data_lake.s3_data_bucket}/data/raw"

  # Target is not needed when data_lake_storage_path is provided:
  target = {
    id = "redshift"
    settings = {
      s3_key_prefix         = "data/raw/{tap}/{table}/v1/"
      s3_bucket             = module.data_lake.s3_data_bucket
      port                  = split(":", module.redshift.endpoint)[1]
      dbname                = "redshift_db"
      default_target_schema = "public"

      host     = split(":", module.redshift.endpoint)[0]
      user     = local.redshift_admin_user
      password = local.redshift_admin_pass
    }
    secrets = {
      aws_access_key_id     = local.aws_credentials_file
      aws_secret_access_key = local.aws_credentials_file
    }
  }
}
