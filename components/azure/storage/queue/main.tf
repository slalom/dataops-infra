/*
* This is the underlying technical component which supports the Storage catalog module for
* building Queue Storage.
*
*/

resource "azurerm_storage_queue" "queue_storage" {
  for_each             = toset(var.queue_storage_names)
  name                 = lower(each.value)
  storage_account_name = var.storage_account_name
  metadata             = var.resource_tags
}
