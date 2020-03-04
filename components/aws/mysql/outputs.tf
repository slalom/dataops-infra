output "endpoint" { value = aws_db_instance.mysql.endpoint }
output "summary" {
  value = <<EOF

MySQL ID:         ${aws_db_instance.mysql.id}
MySQL ARN:        ${aws_db_instance.mysql.arn}
MySQL Endpoint:   ${aws_db_instance.mysql.endpoint}
MySQL Username:   ${aws_db_instance.mysql.admin_username}
MySQL Password:   ${aws_db_instance.mysql.admin_password}
EOF
}
