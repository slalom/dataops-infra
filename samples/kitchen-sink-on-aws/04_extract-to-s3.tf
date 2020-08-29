locals {
  tap_id            = "exchangeratesapi"
  tap_metadata_path = "./taps"
  tap_config_file   = "${local.tap_metadata_path}/.secrets/tap-${local.tap_id}-config.json"
}

output "tap_to_s3_summary" { value = module.tap_to_s3.summary }
module "tap_to_s3" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../catalog/aws/singer-taps"
  name_prefix   = "${local.name_prefix}S3Tap-"
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # ADD OR MODIFY CONFIGURATION HERE:

  scheduled_timezone      = "PST"
  local_metadata_path     = local.tap_metadata_path
  data_lake_metadata_path = "s3://${module.data_lake.s3_metadata_bucket}"
  data_lake_type          = "S3"
  data_lake_storage_path  = "s3://${module.data_lake.s3_data_bucket}/data/raw"

  taps = [ # Learn more and browse taps at: https://www.singer.io
    {
      id       = local.tap_id
      name     = local.tap_id
      schedule = ["1000", "1400"]
      settings = {
        start_date = "2019-01-01T00:00:00Z" # How far back to backfill
        base       = "USD"
      }
      secrets = {
        # Map the name of the secret to the file containing the key:
        api_token  = local.tap_config_file
        user_agent = local.tap_config_file
      }
    }
  ]
}
