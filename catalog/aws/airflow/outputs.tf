output "logging_url" { value = module.airflow_ecs_task.ecs_logging_url }
output "server_launch_cli" { value = module.airflow_ecs_task.ecs_runtask_cli }
output "summary" {
  # value = "test"
  value = <<EOF


Airflow Summary:
 - Airflow URL:    ${coalesce(local.airflow_url, "n/a")}
 - Logging URL:    ${coalesce(module.airflow_ecs_task.ecs_logging_url, "n/a")}
 - Launch command: ${coalesce(module.airflow_ecs_task.ecs_runtask_cli, "n/a")}
 - Logs print command: ${module.ecs_tap_sync_task.ecs_checklogs_cli}
EOF
}
output "airflow_url" { value = local.airflow_url }
