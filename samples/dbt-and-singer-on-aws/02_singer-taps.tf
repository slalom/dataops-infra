output "singer_summary" { value = module.singer_taps_on_aws.summary }
module "singer_taps_on_aws" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../catalog/aws/singer-taps"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # ADD OR MODIFY CONFIGURATION HERE:

  container_image = "slalomggp/singer:pardot-to-s3-csv--pre"

  local_metadata_path     = "./sample-taps" # For most projects, this will be: "../../data/taps"
  data_lake_type          = "S3"
  data_lake_metadata_path = "s3://${module.data_lake_on_aws.s3_metadata_bucket}"
  data_lake_storage_path  = "s3://${module.data_lake_on_aws.s3_data_bucket}/data/raw"
  scheduled_timezone      = "PST"
  scheduled_sync_times    = ["0600"]

  taps = [
    {
      # For 'id', enter any plugin name or alias from the index below, excluding the `tap-` prefix:
      # https://github.com/slalom-ggp/dataops-tools/blob/master/containers/singer/singer_index.yml
      id = "pardot"
      settings = {
        start_date = "2020-02-28T00:00:00Z"
      }
      secrets = {
        email    = "./sample-taps/.secrets/tap-pardot-config.json:email",
        password = "./sample-taps/.secrets/tap-pardot-config.json:password",
        user_key = "./sample-taps/.secrets/tap-pardot-config.json:user_key",
      }
    }
  ]

  # Target is not needed when data_lake_storage_path is provided:
  # target = {
  #   id = "s3-csv"
  #   settings = {
  #     s3_bucket     = module.data_lake_on_aws.s3_data_bucket
  #     s3_key_prefix = "data/raw/{tap}/{table}/{version}/"
  #   }
  #   secrets = {
  #     aws_access_key_id     = "../.secrets/aws-secrets-manager-secrets.yml:S3_CSV_aws_access_key_id"
  #     aws_secret_access_key = "../.secrets/aws-secrets-manager-secrets.yml:S3_CSV_aws_secret_access_key"
  #   }
  # }

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  data_lake_naming_scheme = "{tap}/{table}/{version}/{file}"


  */
}
