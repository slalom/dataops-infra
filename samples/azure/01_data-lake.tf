module "data_lake" {
  source            = "../../catalog/data-lake-on-azure"
  project_shortname = local.config["project_shortname"]
  resource_group    = azurerm_resource_group.project_rg.name
}

output "storage_account" { value = module.data_lake.storage_account }
output "storage_filesystem" { value = module.data_lake.storage_filesystem }
