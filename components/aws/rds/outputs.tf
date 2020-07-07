output "endpoint" {
  description = "The connection endpoint for the new RDS instance."
  value       = aws_db_instance.rds_db.endpoint
}
output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF

RDS ID:       ${aws_db_instance.rds_db.id}
RDS ARN:      ${aws_db_instance.rds_db.arn}
RDS Endpoint: ${aws_db_instance.rds_db.endpoint}
RDS DB Name:  ${aws_db_instance.rds_db.name}

EOF
}
