output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Singer Taps Summary:

 - ECS tasks URL: https://console.aws.amazon.com/ecs/home?region=${var.environment.aws_region}#/clusters/${module.ecs_cluster.ecs_cluster_name}/tasks
 - Sync command:  ${module.ecs_tap_sync_task.ecs_runtask_cli}

 - Logging URL:   ${module.ecs_tap_sync_task.ecs_logging_url}
 - Logs command:  ${module.ecs_tap_sync_task.ecs_checklogs_cli}
EOF
}
