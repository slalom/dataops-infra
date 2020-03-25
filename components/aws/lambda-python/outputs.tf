output "build_temp_dir" {
  description = "Full path to the local folder used to build the python package."
  value       = local.temp_build_folder
}
output "function_ids" {
  description = "A map of function names to the unique function ID (ARN)."
  value = {
    for name in local.function_names :
    name => aws_lambda_function.python_lambda[name].arn
  }
}
output "lambda_iam_role" {
  description = <<EOF
The IAM role used by the lambda function to access resources. Can be used to grant
additional permissions to the role.
EOF
  value = aws_iam_role.iam_for_lambda.name
}
