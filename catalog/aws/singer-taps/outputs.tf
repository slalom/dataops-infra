output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Singer Taps Summary:

 - ECS Tasks URL: https://console.aws.amazon.com/ecs/home?region=${var.environment.aws_region}#/clusters/${module.ecs_cluster.ecs_cluster_name}/tasks
 - Dashboard URLs:
   - ${join("\n   - ", local.dashboard_urls)}
 - Logging URL:
   - ${join("\n   - ", module.ecs_tap_sync_task.*.ecs_logging_url)}
 - State Machine:
   - ${join("\n   - ", module.step_function.*.state_machine_name)}

 NOTE: These CLI actions require setting the profile using a "User Switch Command" from the "Environment" module:
 - Run sync via State Machine:
     aws stepfunctions start-execution --state-machine-arn ${module.step_function.state_machine_arn}
 - Run sync via ECS Task:
     ${module.ecs_tap_sync_task.ecs_runtask_cli}

EOF
}
