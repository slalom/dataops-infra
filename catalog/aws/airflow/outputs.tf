output "logging_url" { value = module.airflow_ecs_task.ecs_logging_url }
# output "webui_endpoint" { value = "${module.airflow_ecs_task.public_ip_address}:8080"} 
output "server_launch_cli" { value = module.airflow_ecs_task.ecs_runtask_cli }
output "summary" {
  # value = "test"
  value = <<EOF

Airflow Summary:
  Airflow URL:    http://${coalesce(module.airflow_ecs_task.load_balancer_dns, "n/a")}:8080
  Launch command: ${coalesce(module.airflow_ecs_task.ecs_runtask_cli, "n/a")}
  Logging URL:    ${coalesce(module.airflow_ecs_task.ecs_logging_url, "n/a")}
EOF
}
