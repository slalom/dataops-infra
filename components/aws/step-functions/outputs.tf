output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF

State Machine Name: ${aws_sfn_state_machine.state_machine.name}
State Machine ARN:  ${aws_sfn_state_machine.state_machine.id}
EOF
}

output "iam_role_arn" {
  description = <<EOF
The IAM role used by the step function to access resources. Can be used to grant
additional permissions to the role.
EOF
  value = aws_iam_role.step_functions_ml_ops_role.arn
}
