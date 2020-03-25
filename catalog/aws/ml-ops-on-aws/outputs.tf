output "summary" {
  description = "Summary of resources created."
  value = module.step-functions.summary
}

output "iam_role_arn" {
  description = <<EOF
The IAM role used by the step function to execute the step function and access related
resources. This can be used to grant additional permissions to the role as needed.
EOF
  value = module.step-functions.iam_role_arn
}