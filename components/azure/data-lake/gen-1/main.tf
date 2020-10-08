/*
* This data lake implementation creates a Gen1 Data Lake Store if configured.
*
*/

locals {
  data_lake_create_flag = var.data_lake_type == "Gen1" ? 1 : 0
}

resource "azurerm_data_lake_store" "data_lake_gen1" {
  # count                    = local.data_lake_create_flag
  name                     = var.data_lake_name
  tags                     = var.resource_tags
  location                 = var.azure_location
  resource_group_name      = var.resource_group_name
  encryption_state         = var.encryption_state
  firewall_allow_azure_ips = var.firewall_allow_azure_ips
  firewall_state           = var.firewall_state
}
