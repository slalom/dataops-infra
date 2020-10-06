output "storage_account_summary" { value = module.storage_account.summary }
module "storage_account" {
  source              = "../../../catalog/azure/storage-account"
  name_prefix         = local.project_shortname
  resource_tags       = local.resource_tags
  azure_location      = local.azure_location
  resource_group_name = module.rg.resource_group_name

  # CONFIGURE HERE:
  storage_account_name = "test"

}
