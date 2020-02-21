output "build_temp_dir" {
  value = local.build_temp_dir
}
output "python_zip_size" {
  value = format("%.2fMB", aws_lambda_function.python_lambda.source_code_size / 1000000)
}
