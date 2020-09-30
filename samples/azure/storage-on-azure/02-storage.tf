output "storage_summary" { value = module.storage.summary }
module "storage" {
  source               = "../../../catalog/azure/storage"
  name_prefix          = local.project_shortname
  resource_tags        = local.resource_tags
  storage_account_name = module.storage_account.storage_account_name

  # CONFIGURE HERE:
  container_names     = ["container1", "container2"]
  table_storage_names = ["table1", "table2", "table3"]
  queue_storage_names = ["queue", "queue2"]

}
