# OPTIONAL: Only if using 'bring your own model'

module "ecr_image_byo_model" {
  source        = "../../../components/aws/ecr-image-2"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  repository_name   = var.byo_model_repo_name
  source_image_path = var.byo_model_source_image_path
  tag               = var.byo_model_tag
}