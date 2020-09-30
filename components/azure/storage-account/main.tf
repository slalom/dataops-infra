/*
* This is the underlying technical component which supports the Storage Account catalog module.
*
*/

resource "azurerm_storage_account" "storage_account" {
  name                      = join("", [lower(var.name_prefix), lower(var.storage_account_name)])
  tags                      = var.resource_tags
  location                  = var.azure_location
  resource_group_name       = var.resource_group_name
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  account_kind              = var.account_kind
  access_tier               = var.access_tier
  enable_https_traffic_only = var.enable_https_traffic_only
  allow_blob_public_access  = var.allow_blob_public_access
  is_hns_enabled            = var.is_hns_enabled
}
