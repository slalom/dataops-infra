/*
* Deploys a Storage Account within a subscription.
*
*/

module "storage_account" {
  source                    = "../../../components/azure/storage-account"
  name_prefix               = var.name_prefix
  resource_tags             = var.resource_tags
  azure_location            = var.azure_location
  resource_group_name       = var.resource_group_name
  storage_account_name      = var.storage_account_name
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  account_kind              = var.account_kind
  access_tier               = var.access_tier
  enable_https_traffic_only = var.enable_https_traffic_only
  allow_blob_public_access  = var.allow_blob_public_access
  is_hns_enabled            = var.is_hns_enabled
}
