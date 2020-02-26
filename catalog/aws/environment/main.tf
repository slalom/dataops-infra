module "vpc" {
  # TODO: Revert to stable source
  source        = "../../../components/aws/vpc"
  name_prefix   = var.name_prefix
  aws_region    = var.aws_region
  resource_tags = var.resource_tags
}
