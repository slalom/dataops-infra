output "data_lake_summary" { value = module.data_lake.summary }
module "data_lake" {
  source = "../../catalog/aws/data-lake"
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=main"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags
}
