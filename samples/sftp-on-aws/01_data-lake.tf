output "data_lake_summary" { value = module.data_lake.summary }
module "data_lake" {

  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../catalog/aws/data-lake"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # ADD OR MODIFY CONFIGURATION HERE:


}
