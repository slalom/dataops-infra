/*
* This data lake implementation creates a Gen2 Data Lake Store if configured.
*
*/

locals {
  data_lake_create_flag = var.data_lake_type == "Gen2" ? 1 : 0
}

resource "azurerm_storage_data_lake_gen2_filesystem" "data_lake_gen2" {
  # count                    = local.data_lake_create_flag
  name               = var.data_lake_name
  storage_account_id = var.storage_account_id
  # properties               = var.resource_tags
}
