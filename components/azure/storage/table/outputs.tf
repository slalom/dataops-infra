output "table_storage_names" {
  description = "The name of the Table(s) created."
  value       = values(azurerm_storage_table.table_storage)[*].name
}
