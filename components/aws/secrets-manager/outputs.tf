# TODO:  BUGFIX:'summary' and 'arn_list' appear to be returning null
output "summary" {
  value = <<EOF

Secrets Summary:
 - Secret ARNs: ${coalesce(join(", ", aws_secretsmanager_secret.secrets.*.arn), "(empty)")}
EOF
}
output "secrets_ids" {
  value = {
    for secret_id in var.secrets_names :
    secret_id => aws_secretsmanager_secret.secrets[secret_id].arn
  }
}
