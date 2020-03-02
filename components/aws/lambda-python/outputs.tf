output "build_temp_dir" {
  value = local.temp_build_folder
}
output "python_zip_size" {
  value = length(aws_lambda_function.python_lambda) == 0 ? null : format("%.2fMB", max(aws_lambda_function.python_lambda.*.source_code_size) / 1000000)
}
