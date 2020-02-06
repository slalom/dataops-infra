# NOTE: Requires AWS policy 'AmazonRedshiftFullAccess' on the terraform account

data "aws_region" "current" {}

locals {
  name_prefix = "${var.name_prefix}-RS"
  aws_region = coalesce(coalesce(var.aws_region, data.aws_region.current.name)
  vpc_id = coalesce(var.vpc_id, module.vpc.vpc_id)
  subnets = coalesce(var.subnets, module.vpc.public_subnets)
}

module "vpc" {
  source        = "../../../modules/aws/vpc"
  disabled      = var.create_vpc ? false : true
  name_prefix   = local.name_prefix
  aws_region    = local.aws_region
  resource_tags = var.resource_tags
}

module "redshift" {
  source              = "../../../modules/aws/redshift"
  name_prefix         = local.name_prefix
  subnets             = local.subnets
  resource_tags       = var.resource_tags
  skip_final_snapshot = var.skip_final_snapshot
  admin_password      = var.admin_password
  node_type           = var.node_type
  num_nodes           = var.num_nodes
  kms_key_id          = var.kms_key_id
  elastic_ip          = var.elastic_ip
  jdbc_port           = var.jdbc_port
  s3_logging_bucket   = var.s3_logging_bucket
  s3_logging_path     = var.s3_logging_path
}
