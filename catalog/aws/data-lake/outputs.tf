output "summary" {
  value = <<EOF


Data Lake Summary:
 - Data Bucket: ${aws_s3_bucket.s3_data_bucket.id}
 - Meta Bucket: ${aws_s3_bucket.s3_metadata_bucket.id}
 - Logs Bucket: ${aws_s3_bucket.s3_logging_bucket.id}
EOF
}
#  - Lambda Function:
#    - Zip File Size: ${coalesce(module.triggered_lambda.python_zip_size, "n/a")}
output "s3_data_bucket" {
  value = aws_s3_bucket.s3_data_bucket.id
}
output "s3_metadata_bucket" {
  value = aws_s3_bucket.s3_metadata_bucket.id
}
output "s3_logging_bucket" {
  value = aws_s3_bucket.s3_logging_bucket.id
}
output "lambda_python_zip_size" {
  value = module.triggered_lambda.python_zip_size
}
