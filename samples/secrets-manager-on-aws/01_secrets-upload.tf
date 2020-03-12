output "secrets_summary" { value = module.secrets.summary }
module "secrets" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../components/aws/secrets-manager"
  name_prefix   = "${local.name_prefix}test-"
  resource_tags = local.resource_tags
  environment   = module.env.environment

  # ADD OR MODIFY CONFIGURATION HERE:

  secrets_map = {
    SAMPLE_username = "../.secrets/aws-secrets-manager-secrets.yml:SAMPLE_username",
    SAMPLE_password = "../.secrets/aws-secrets-manager-secrets.yml:SAMPLE_password",
  }

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  kms_key_id = null # when null, use the default KMS key

  */
}
