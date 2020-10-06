output "data_lake_name" {
  description = "The name of the Data Lake created."
  value       = var.data_lake_name
}

output "data_lake_type" {
  description = "The generation type of the Data Lake created (i.e. Gen1 or Gen2)."
  value       = var.data_lake_type
}
