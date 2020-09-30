/*
* This is the underlying technical component which supports the Storage catalog module for
* building Table Storage.
*
*/

resource "azurerm_storage_table" "table_storage" {
  for_each             = toset(var.table_storage_names)
  name                 = lower(each.value)
  storage_account_name = var.storage_account_name
}
