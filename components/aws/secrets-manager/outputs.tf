locals {
  merged_secrets_map = merge(
    local.existing_secrets_ids_map, {
      for created_name in keys(local.new_secrets_map) :
      created_name => var.use_parameter_store ? aws_ssm_parameter.secrets[created_name].id : aws_secretsmanager_secret.secrets[created_name].id
    }
  )
}

output "summary" {
  description = "Summary of resources created by this module."
  value = <<EOF


Secrets Summary:
 - Secret ARNs:
 ${"\t"}${
  coalesce(join("\n\t",
    [
      for name, id in local.merged_secrets_map :
      "${name} => ${id}"
    ]
  ), "(none)")
}
EOF
}
output "secrets_ids" {
  description = "A map of secrets names to each secret's unique ID within AWS Secrets Manager."
  value       = local.merged_secrets_map
}
