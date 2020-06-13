output "state_machine_name" {
  description = "The State Machine name."
  value       = aws_sfn_state_machine.state_machine.name
}

output "state_machine_arn" {
  description = "The State Machine arn."
  value       = aws_sfn_state_machine.state_machine.id
}

output "iam_role_arn" {
  description = <<EOF
The IAM role used by the step function to access resources. Can be used to grant
additional permissions to the role.
EOF
  value       = aws_iam_role.step_functions_role.arn
}

output "state_machine_url" {
  description = <<EOF

EOF
  value = "https://${var.environment.aws_region}.console.aws.amazon.com/states/home?region=${var.environment.aws_region}#/statemachines/view/${aws_sfn_state_machine.state_machine.id}"
}
