# OPTIONAL: Only if using 'bring your own model'

module "ecr_image_byo_model" {
  count                = var.built_in_model_image == null ? 1 : 0
  source               = "../../../components/aws/ecr-image"
  name_prefix          = var.name_prefix
  environment          = var.environment
  resource_tags        = var.resource_tags
  aws_credentials_file = var.aws_credentials_file

  repository_name   = var.byo_model_image_name
  source_image_path = var.byo_model_source_image_path
  tag               = var.byo_model_image_tag
}
