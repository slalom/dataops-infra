/*
* Deploys either a Gen1 or Gen2 Data Lake Store.
*
*/

module "data_lake_gen1" {
  source                   = "../../../components/azure/data-lake/gen-1"
  count                    = var.data_lake_type == "Gen1" ? 1 : 0
  name_prefix              = var.name_prefix
  data_lake_name           = var.data_lake_name
  data_lake_type           = var.data_lake_type
  resource_tags            = var.resource_tags
  azure_location           = var.azure_location
  resource_group_name      = var.resource_group_name
  encryption_state         = var.encryption_state
  firewall_allow_azure_ips = var.firewall_allow_azure_ips
  firewall_state           = var.firewall_state
}

module "data_lake_gen2" {
  source                   = "../../../components/azure/data-lake/gen-2"
  count                    = var.data_lake_type == "Gen2" ? 1 : 0
  name_prefix              = var.name_prefix
  data_lake_name           = var.data_lake_name
  data_lake_type           = var.data_lake_type
  resource_tags            = var.resource_tags
  storage_account_id       = var.storage_account_id
}
