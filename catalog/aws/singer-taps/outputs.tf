output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Singer Taps Summary:

 - Dashboard URL: https://console.aws.amazon.com/cloudwatch/home?region=${var.environment.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main.dashboard_name}
 - State Machine: ${module.step_function.state_machine_name}

 NOTE: Running from CLI require setting the profile using a "User Switch Command" from the "Environment" module:
 - Run sync via State Machine:
     aws stepfunctions start-execution --state-machine-arn ${module.step_function.state_machine_arn}

EOF
}
