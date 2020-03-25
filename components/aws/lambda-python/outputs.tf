output "build_temp_dir" {
  description = "Full path to the local folder used to build the python package."
  value       = local.temp_build_folder
}
output "function_ids" {
  value = {
    for name in local.function_names :
    name => aws_lambda_function.python_lambda[name].arn
  }
}
output "lambda_iam_role" { value = aws_iam_role.iam_for_lambda.name }
