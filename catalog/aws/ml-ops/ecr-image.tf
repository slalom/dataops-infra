# OPTIONAL: Only if using 'bring your own model'

module "ecr_image_byo_model" {
  source        = "../../../components/aws/ecr-image"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  is_disabled       = var.built_in_model_image != null ? true : false
  repository_name   = var.byo_model_image_name
  source_image_path = var.byo_model_image_source_path
  tag               = var.byo_model_image_tag
}
