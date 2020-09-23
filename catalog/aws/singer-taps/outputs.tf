output "summary" {
  description = "Summary of resources created by this module."
  value = <<EOF


Singer Taps Summary:

 - Dashboard URLs:
   - ${join("\n   - ", local.dashboard_urls)}
 - Logging URLs:
   - ${join("\n   - ", module.ecs_tap_sync_task.*.ecs_logging_url)}
 - State Machines:
   - ${join("\n   - ", module.step_function.*.state_machine_name)}
 - ECS Tasks URL: https://console.aws.amazon.com/ecs/home?region=${var.environment.aws_region}#/clusters/${module.ecs_cluster.ecs_cluster_name}/tasks

 NOTE: Running from CLI require setting the profile using a "User Switch Command" from the "Environment" module:
 - Run sync via State Machine:
    ${join("\n   - ", [
  for sf in module.step_function :
  "aws stepfunctions start-execution --state-machine-arn ${sf.state_machine_arn} --region ${var.environment.aws_region}"
])}

EOF
}
