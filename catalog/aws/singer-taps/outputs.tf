output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Singer Taps Summary:

 - ECS tasks URL: https://console.aws.amazon.com/ecs/home?region=${var.environment.aws_region}#/clusters/${module.ecs_cluster.ecs_cluster_name}/tasks
 - Dashboard URL: https://console.aws.amazon.com/cloudwatch/home?region=${var.environment.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}
 - Logging URL:   ${module.ecs_tap_sync_task.ecs_logging_url}

 NOTE: This CLI action require setting the profile using a "User Switch Command" from the "Environment" module:
 - Sync command:  ${module.ecs_tap_sync_task.ecs_runtask_cli}
EOF
}
