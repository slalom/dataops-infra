output "airflow_url" {
  description = "Link to the airflow web UI."
  value       = local.airflow_url
}
output "logging_url" {
  description = "Link to Airflow logs in Cloudwatch."
  value       = module.airflow_ecs_task.ecs_logging_url
}
output "server_launch_cli" {
  description = "Command to launch the Airflow web server via ECS."
  value       = module.airflow_ecs_task.ecs_runtask_cli
}
output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Airflow Summary:
 - Airflow URL:    ${coalesce(local.airflow_url, "n/a")}
 - Logging URL:    ${coalesce(module.airflow_ecs_task.ecs_logging_url, "n/a")}
 - Launch command: ${coalesce(module.airflow_ecs_task.ecs_runtask_cli, "n/a")}
EOF
}
