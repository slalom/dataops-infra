# NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

data "aws_region" "current" {}

locals {
  name_prefix    = "${var.name_prefix}-RS"
  aws_region     = coalesce(var.aws_region, data.aws_region.current.name)
  vpc_id         = coalesce(var.vpc_id, module.vpc.vpc_id)
  public_subnets = coalesce(var.public_subnets, module.vpc.public_subnets)
  create_vpc     = var.vpc_id == null && var.public_subnets == null
}

module "vpc" {
  source        = "../../../components/aws/vpc"
  disabled      = ! local.create_vpc
  name_prefix   = local.name_prefix
  aws_region    = local.aws_region
  resource_tags = var.resource_tags
}

module "mysql" {
  source              = "../../../components/aws/mysql"
  name_prefix         = local.name_prefix
  subnets             = local.public_subnets
  resource_tags       = var.resource_tags
  skip_final_snapshot = var.skip_final_snapshot
  admin_password      = var.admin_password
  instance_class      = var.instance_class
  engine              = var.engine
  engine_version      = var.engine_version
  num_nodes           = var.num_nodes
  kms_key_id          = var.kms_key_id
  elastic_ip          = var.elastic_ip
  jdbc_port           = var.jdbc_port
  s3_logging_bucket   = var.s3_logging_bucket
  s3_logging_path     = var.s3_logging_path
}
