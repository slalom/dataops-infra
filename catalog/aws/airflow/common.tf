locals {
  name_prefix     = "${var.name_prefix}Airflow-"
  aws_region      = var.aws_region
  public_subnets  = coalesce(var.public_subnets, module.vpc.public_subnets)
  private_subnets = coalesce(var.private_subnets, module.vpc.private_subnets)
  create_vpc      = var.vpc_id == null && var.private_subnets == null && var.public_subnets == null
}
data "aws_subnet" "public_subnet_lookup" {
    id = (var.public_subnets != null ? var.public_subnets : module.vpc.public_subnets)[0]
}
data "aws_subnet" "private_subnet_lookup" {
    id = (var.private_subnets != null ? var.private_subnets : module.vpc.private_subnets)[0]
}
locals {
  vpc_id = coalesce(
    var.vpc_id,
    module.vpc.vpc_id,
    data.aws_subnet.public_subnet_lookup.vpc_id,
    data.aws_subnet.private_subnet_lookup.vpc_id
  )
}

module "vpc" {
  source        = "../../../modules/aws/vpc"
  disabled      = ! local.create_vpc
  name_prefix   = local.name_prefix
  aws_region    = local.aws_region
  resource_tags = var.resource_tags
}
