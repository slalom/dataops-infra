# Creates an empty azure network

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "azurerm_virtual_network" "project_network" {
  name                = "${var.project_shortname}-network"
  resource_group_name = var.resource_group
  location            = data.azurerm_resource_group.resource_group.location
  address_space       = ["10.0.0.0/16"]
}
