output "summary" {
  value = <<EOF


Singer Taps Summary:
 - Run command: ${module.ecs_tap_sync_task.ecs_runtask_cli}
 - Logs print command: ${module.ecs_tap_sync_task.ecs_checklogs_cli}
 - Logging URL: ${module.ecs_tap_sync_task.ecs_logging_url}
EOF
}
