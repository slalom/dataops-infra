output "summary" {
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
  value = local.merged_secrets_map
}
