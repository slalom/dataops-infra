output "queue_storage_names" {
  description = "The name of the Queue(s) created."
  value       = values(azurerm_storage_queue.queue_storage)[*].name
}
