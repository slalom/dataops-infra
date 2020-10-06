output "storage_account_name" {
  description = "The name of the new Storage Account created."
  value       = azurerm_storage_account.storage_account.name
}

output "storage_account_id" {
  description = "The ID for the new Storage Account created."
  value       = azurerm_storage_account.storage_account.id
}
