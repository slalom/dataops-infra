output "data_lake_summary" { value = module.data_lake.summary }
module "data_lake" {
  source              = "../../../catalog/azure/data-lake"
  name_prefix         = local.project_shortname
  resource_tags       = local.resource_tags
  azure_location      = local.azure_location
  resource_group_name = module.rg.resource_group_name

  # CONFIGURE HERE:
  data_lake_name = "dataopsinfradatalake"
  data_lake_type = "Gen1" # Accepted values are Gen1 or Gen2
  firewall_state = "Disabled"
}
