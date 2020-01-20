output "logging_url" { value = module.airflow_server.ecs_logging_url }
output "webui_endpoint" { value = "${module.airflow_server.public_ip_address}:8080"} 
output "server_launch_cli" { value = module.airflow_server.ecs_fargate_runtask_cli }
