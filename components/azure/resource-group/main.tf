/*
* This is the underlying technical component which supports the Resource Group catalog module.
*
*/

resource "azurerm_resource_group" "rg" {
  name     = "${lower(var.name_prefix)}-${lower(var.resource_group_name)}"
  location = var.azure_location
  tags     = var.resource_tags
}
