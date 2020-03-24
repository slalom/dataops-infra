output "endpoint" {
  description = "The MySQL connection endpoint for the new server."
  value       = module.mysql.endpoint
}
output "summary" {
  description = "Summary of resources created by this module."
  value       = module.mysql.summary
}
