locals {
  tap_metadata_path = "./taps"
  tap_config_file   = "${local.tap_metadata_path}/.secrets/tap-covid-19-config.json"
}

output "singer_summary" { value = module.singer_taps_on_aws.summary }
module "singer_taps_on_aws" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../catalog/aws/singer-taps"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # ADD OR MODIFY CONFIGURATION HERE:

  local_metadata_path     = local.tap_metadata_path
  data_lake_type          = "S3"
  data_lake_metadata_path = "s3://${module.data_lake_on_aws.s3_metadata_bucket}"
  data_lake_storage_path  = "s3://${module.data_lake_on_aws.s3_data_bucket}/data/raw"
  scheduled_timezone      = "PST"

  taps = [
    {
      # For 'id', enter any plugin name or alias from the index below, excluding the `tap-` prefix:
      # https://github.com/slalom-ggp/dataops-tools/blob/main/containers/singer/singer_index.yml
      id       = "covid-19"
      schedule = ["0600"]
      settings = {
        start_date = "2020-02-28T00:00:00Z"
      }
      secrets = {
        # Maps the name of the needed secret to the file containing a key
        # under the same name:
        api_token  = local.tap_config_file
        user_agent = local.tap_config_file
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

  container_image          = "dataopstk/tapdance:pardot-to-s3-csv--pre"
  data_file_naming_scheme  = "{tap}/{table}/{version}/{file}"
  state_file_naming_scheme = "{tap}/{table}/state/{tap}-{table}-v{version}-state.json"

  */
}
