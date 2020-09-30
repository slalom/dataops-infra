/*
* This is the underlying technical component which supports the Storage catalog module for
* building Containers.
*
*/

resource "azurerm_storage_container" "containers" {
  for_each              = toset(var.container_names)
  name                  = lower(each.value)
  metadata              = var.resource_tags
  storage_account_name  = var.storage_account_name
  container_access_type = var.container_access_type
}
