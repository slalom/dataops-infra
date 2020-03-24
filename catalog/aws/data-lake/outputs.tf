output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF


Data Lake Summary:
 - Data Bucket: ${local.data_bucket_name}
 - Meta Bucket: ${aws_s3_bucket.s3_metadata_bucket.id}
 - Logs Bucket: ${aws_s3_bucket.s3_logging_bucket.id}
EOF
}
output "s3_data_bucket" {
  description = "The S3 bucket used for data storage."
  value       = local.data_bucket_name
}
output "s3_metadata_bucket" {
  description = "The S3 bucket used for metadata file storage."
  value       = aws_s3_bucket.s3_metadata_bucket.id
}
output "s3_logging_bucket" {
  description = "The S3 bucket used for log file storage."
  value       = aws_s3_bucket.s3_logging_bucket.id
}
