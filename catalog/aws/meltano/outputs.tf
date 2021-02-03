output "meltano_url" {
  description = "Link to the meltano web UI."
  value       = local.meltano_url
}
output "logging_url" {
  description = "Link to Meltano logs in Cloudwatch."
  value       = module.meltano_ecs_task.ecs_logging_url
}
output "server_launch_cli" {
  description = "Command to launch the Meltano web server via ECS."
  value       = module.meltano_ecs_task.ecs_runtask_cli
}
output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Meltano Summary:
 - Meltano URL:    ${coalesce(local.meltano_url, "n/a")}
 - Logging URL:    ${coalesce(module.meltano_ecs_task.ecs_logging_url, "n/a")}
 - Launch command: ${coalesce(module.meltano_ecs_task.ecs_runtask_cli, "n/a")}
EOF
}
