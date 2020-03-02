output "secrets_summary" { value = module.secrets.summary }
module "secrets" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../components/aws/secrets-manager"
  name_prefix   = "${local.name_prefix}pardot-"
  resource_tags = local.resource_tags
  secrets_file  = "./sample-taps/sample-creds-config.json"

  # ADD OR MODIFY CONFIGURATION HERE:

  secrets_file_map = {
    SAMPLE_username = "username",
    SAMPLE_password = "password",
    SAMPLE_user_key = "user_key",
  }

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  kms_key_id = null # when null, use the default KMS key

  */
}