# NOTE: Requires AWS policy 'AmazonRedshiftFullAccess' on the terraform account

data "aws_region" "current" {}

locals {
  aws_region = var.aws_region != null ? var.aws_region : data.aws_region.current.name
}

module "vpc" {
  source      = "../../../modules/aws/vpc"
  name_prefix = var.name_prefix
  aws_region  = local.aws_region
}

module "redshift" {
  source              = "../../../modules/aws/redshift"
  name_prefix         = var.name_prefix
  subnets             = module.vpc.public_subnet_ids
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
