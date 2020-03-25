output "endpoint" {
  description = "The Redshift connection endpoint for the new server."
  value       = module.redshift.endpoint
}
output "summary" {
  description = "Summary of resources created by this module."
  value       = module.redshift.summary
}
