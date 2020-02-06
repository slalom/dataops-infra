output "logging_url" { value = module.airflow_ecs_task.ecs_logging_url }
# output "webui_endpoint" { value = "${module.airflow_ecs_task.public_ip_address}:8080"} 
output "server_launch_cli" { value = module.airflow_ecs_task.ecs_runtask_cli }
output "summary" {
  value = <<EOF

Airflow Summary:
  Launch command: ${module.airflow_ecs_task.ecs_runtask_cli}
  Logging URL:    ${module.airflow_ecs_task.ecs_logging_url}
  Airflow URL:    http://${module.airflow_ecs_task.load_balancer_dns}:8080
EOF
}
