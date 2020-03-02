output "singer_summary" { value = module.singer_taps_on_aws.summary }
module "singer_taps_on_aws" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../catalog/aws/singer-taps"
  name_prefix   = local.name_prefix
  resource_tags = local.resource_tags
  environment   = module.env.environment

  # ADD OR MODIFY CONFIGURATION HERE:

  source_code_folder    = "../data/taps"
  source_code_s3_bucket = module.data_lake_on_aws.s3_metadata_bucket
  scheduled_timezone    = "PST"
  scheduled_sync_times  = ["0600"]
  taps = [
    {
      # Update with correct source information
      id = "sample"
      settings = {
        # Update with any extract settings
        start_date = "2020-02-28T00:00:00Z"
      }
      secrets = {
        # Update with names of secrets keys
        email    = module.secrets.secrets_ids["SAMPLE_username"]
        password = module.secrets.secrets_ids["SAMPLE_password"]
      }
    }
  ]

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  path_pattern = "{tap}/{table}/{version}/{file}"
  target = {
    id = "s3-csv"
    settings = {
      s3_bucket     = module.data_lake_on_aws.s3_data_bucket
      s3_key_prefix = "data/raw/{tap}/{table}/{version}/"
    }
    secrets = {}
  }

  s3_data_bucket = module.data_lake_on_aws.s3_data_bucket
  s3_data_root   = "data/raw"

  */
}
