locals {
  data_lake_name = var.data_lake_type == "Gen1" ? module.data_lake_gen1.data_lake_name : module.data_lake_gen2.data_lake_name
  data_lake_type = var.data_lake_type == "Gen1" ? module.data_lake_gen1.data_lake_type : module.data_lake_gen2.data_lake_type
}

output "summary" {
  description = "Summary of resources created by this module."
  value       = <<EOF

Data Lake Summary:
  - Name: ${local.data_lake_name}
  - Type: ${local.data_lake_type}
  ${module.data_lake_gen2.data_lake_type}

EOF
}

output "data_lake_name" {
  description = "The Data Lake name value(s) of the newly created Data Lake(s)."
  value       = local.data_lake_name
}
