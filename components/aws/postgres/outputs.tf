output "endpoint" { value = aws_db_instance.postgres.endpoint }
output "summary" {
  value = <<EOF

Postgres ID:         ${aws_db_instance.postgres.id}
Postgres ARN:        ${aws_db_instance.postgres.arn}
Postgres Endpoint:   ${aws_db_instance.postgres.endpoint}
Postgres Username:   ${aws_db_instance.postgres.username}
Postgres Password:   ${aws_db_instance.postgres.password}


EOF
}
