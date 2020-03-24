output "endpoint" {
  description = "The Postgres connection endpoint for the new server."
  value       = module.postgres.endpoint
}
output "summary" {
  description = "Summary of resources created by this module."
  value       = module.postgres.summary
}
