output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


DBT Summary:
 - Run command: ${module.ecs_task.ecs_runtask_cli}
 - Logging URL: ${module.ecs_task.ecs_logging_url}
EOF
}
