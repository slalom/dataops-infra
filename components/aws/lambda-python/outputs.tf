output "build_temp_dir" {
  value = local.temp_build_folder
}
output "function_ids" {
  value = {
    for name in local.function_names :
    name => aws_lambda_function.python_lambda[name].arn
  }
}
output "lambda_iam_role" { value = aws_iam_role.iam_for_lambda.name }
