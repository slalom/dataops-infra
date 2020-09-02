output "secrets_mgr_summary" { value = module.secrets_mgr.summary }
module "secrets_mgr" {
  source        = "../../components/aws/secrets-manager"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  secrets_map = {
    project_shortname = local.yaml_config_path
  }

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  kms_key_id = null # when null, use the default KMS key

  */
}
