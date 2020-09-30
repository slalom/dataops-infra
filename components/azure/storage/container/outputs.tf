output "container_names" {
  description = "The name of the Storage Container(s) created."
  value       = values(azurerm_storage_container.containers)[*].name
}
