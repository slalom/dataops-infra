output "endpoint" {
  description = "The connection endpoint for the new Redshift instance."
  value       = aws_redshift_cluster.redshift.endpoint
}
output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF

Redshift Cluster ID: ${aws_redshift_cluster.redshift.id}
Redshift ARN:        ${aws_redshift_cluster.redshift.arn}
Redshift endpoint:   ${aws_redshift_cluster.redshift.endpoint}
EOF
}
