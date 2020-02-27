output "endpoint" { value = aws_mysql_db.mysql.endpoint }
output "summary" {
  value = <<EOF

MySQL ID:         ${aws_mysql_db.mysql.id}
MySQL ARN:        ${aws_mysql_db.mysql.arn}
MySQL Endpoint:   ${aws_mysql_db.mysql.endpoint}
EOF
}
