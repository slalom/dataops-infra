/*
* Deploys Storage Containers, Queue Storage, and Table Storage within a storage
* account.
*
*/

module "containers" {
  source                = "../../../components/azure/storage/container"
  name_prefix           = var.name_prefix
  resource_tags         = var.resource_tags
  storage_account_name  = var.storage_account_name
  container_names       = var.container_names
  container_access_type = var.container_access_type
}

module "table_storage" {
  source               = "../../../components/azure/storage/table"
  name_prefix          = var.name_prefix
  resource_tags        = var.resource_tags
  storage_account_name = var.storage_account_name
  table_storage_names  = var.table_storage_names
}

module "queue_storage" {
  source               = "../../../components/azure/storage/queue"
  name_prefix          = var.name_prefix
  resource_tags        = var.resource_tags
  storage_account_name = var.storage_account_name
  queue_storage_names  = var.queue_storage_names
}
