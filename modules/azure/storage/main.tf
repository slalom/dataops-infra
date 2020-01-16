# Creates an empty azure storage account with data lake gen2

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group
}

resource "azurerm_storage_account" "project_storage_account" {
  name                     = "${var.project_shortname}-storage"
  resource_group_name      = data.azurerm_resource_group.resource_group.name
  location                 = data.azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = "true"
}

resource "azurerm_storage_data_lake_gen2_filesystem" "project_fs" {
  name               = "${var.project_shortname}-storage-fs"
  storage_account_id = azurerm_storage_account.project_storage_account.id

  properties = {
    hello = "aGVsbG8="
  }
}
