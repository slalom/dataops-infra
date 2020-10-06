locals {
   resource_group_name = module.rg.resource_group_name
}

output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF

Resource Group Name: ${local.resource_group_name}


EOF
}

output "resource_group_name" {
  description = "The `resource_group_name` value to be passed to other Azure Infrastructure Catalog modules."
  value       = local.resource_group_name
}
