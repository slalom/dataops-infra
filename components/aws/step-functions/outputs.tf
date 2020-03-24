output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF

State Machine Name: ${aws_sfn_state_machine.state_machine.name}
State Machine ARN:  ${aws_sfn_state_machine.state_machine.id}
EOF
}
