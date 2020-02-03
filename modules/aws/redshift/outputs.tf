output "endpoint" { value = aws_redshift_cluster.redshift.endpoint }
output "summary" {
  value = <<EOF

Redshift Cluster ID: ${aws_redshift_cluster.redshift.id}
Redshift ARN:        ${aws_redshift_cluster.redshift.arn}
Redshift endpoint:   ${aws_redshift_cluster.redshift.endpoint}
EOF
}
