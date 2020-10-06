locals {
  storage_account_name = module.storage_account.storage_account_name
  storage_account_id   = module.storage_account.storage_account_id
}

output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF

Storage Account Name: ${local.storage_account_name}

EOF
}

output "storage_account_name" {
  description = "The `storage_account_name` value of the newly created storage account."
  value       = local.storage_account_name
}

output "storage_account_id" {
  description = "The ID for the new Storage Account created."
  value       = local.storage_account_id
}
