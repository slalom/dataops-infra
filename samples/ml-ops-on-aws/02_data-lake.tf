module "source_repository" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source        = "../../catalog/aws/data-lake"
  name_prefix   = "${lower(local.name_prefix)}source-repository-"
  environment   = module.env.environment
  resource_tags = local.resource_tags
}

module "feature_store" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source        = "../../catalog/aws/data-lake"
  name_prefix   = "${lower(local.name_prefix)}feature-store-"
  environment   = module.env.environment
  resource_tags = local.resource_tags
}

module "extracts_store" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source        = "../../catalog/aws/data-lake"
  name_prefix   = "${lower(local.name_prefix)}extracts-store-"
  environment   = module.env.environment
  resource_tags = local.resource_tags
}

module "model_store" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source        = "../../catalog/aws/data-lake"
  name_prefix   = "${lower(local.name_prefix)}model-store-"
  environment   = module.env.environment
  resource_tags = local.resource_tags
}

module "output_store" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source        = "../../catalog/aws/data-lake"
  name_prefix   = "${lower(local.name_prefix)}output-store-"
  environment   = module.env.environment
  resource_tags = local.resource_tags
}
