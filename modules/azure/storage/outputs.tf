output "storage_account" { value = azurerm_storage_account.project_storage_account.name }
output "storage_filesystem" { value = azurerm_storage_data_lake_gen2_filesystem.project_fs.name }
output "summary" { value = "" }
