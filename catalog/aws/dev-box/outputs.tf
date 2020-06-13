output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Dev Box Summary:

 - Logging URL:   ${module.ecs_tap_sync_task.ecs_logging_url}

 NOTE: This CLI action require setting the profile using a "User Switch Command" from the "Environment" module:
 - Sync command:  ${module.ecs_tap_sync_task.ecs_runtask_cli}
EOF
}
