module "data_lake" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source        = "../../catalog/aws/data-lake"
  name_prefix   = "${local.project_shortname}-Tableau-"
  environment   = module.env.environment
  resource_tags = local.resource_tags
}
