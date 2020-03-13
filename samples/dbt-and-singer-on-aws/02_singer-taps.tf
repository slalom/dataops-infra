output "singer_summary" { value = module.singer_taps_on_aws.summary }
module "singer_taps_on_aws" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../catalog/aws/singer-taps"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

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
        SAMPLE_username = "./sample-taps/sample-creds-config.json:username",
        SAMPLE_password = "./sample-taps/sample-creds-config.json:password",
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
    secrets = {
      aws_access_key_id     = "../.secrets/aws-secrets-manager-secrets.yml:S3_CSV_aws_access_key_id"
      aws_secret_access_key = "../.secrets/aws-secrets-manager-secrets.yml:S3_CSV_aws_secret_access_key"
    }
  }

  s3_data_bucket = module.data_lake_on_aws.s3_data_bucket
  s3_data_root   = "data/raw"

  */
}
