output "summary" {
  value = <<EOF

Lambda Function Python Zip Size: ${module.triggered_lambda.python_zip_size}
EOF
}
output "lambda_python_zip_size" {
  value = module.triggered_lambda.python_zip_size
}
