output "endpoint" { value = aws_db_instance.rds_db.endpoint }
output "summary" {
  value = <<EOF

RDS ID:         ${aws_db_instance.rds_db.id}
RDS ARN:        ${aws_db_instance.rds_db.arn}
RDS Endpoint:   ${aws_db_instance.rds_db.endpoint}

EOF
}
