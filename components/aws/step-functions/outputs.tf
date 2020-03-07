output "summary" {
  value = <<EOF

State Machine Name: ${aws_sfn_state_machine.state_machine.name}
State Machine ARN:  ${aws_sfn_state_machine.state_machine.id}
EOF
}

output "iam_role_arn"{
  value = aws_iam_role.step_functions_ml_ops_role.arn
}
