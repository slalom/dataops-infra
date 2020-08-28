output "data_lake_summary" { value = module.data_lake.summary }
module "data_lake" {
  source             = "../../../catalog/azure/data-lake"
  name_prefix        = local.project_shortname
  resource_tags      = local.resource_tags
  storage_account_id = module.storage_account.storage_account_id

  # CONFIGURE HERE:
  data_lake_name = "dataopsinfradatalake"
  data_lake_type = "Gen2" # Accepted values are Gen1 or Gen2
}
