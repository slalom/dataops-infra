locals {
  vpc_id = var.vpc_id != null ? var.vpc_id : module.vpc.vpc_id
  public_subnets = coalesce(var.public_subnets, module.vpc.public_subnets)
  private_subnets = coalesce(var.private_subnets, module.vpc.private_subnets)
  name_prefix = "${var.name_prefix}Airflow-"
}

module "vpc" {
  source        = "../../../modules/aws/vpc"
  disabled      = var.create_vpc ? false : true
  name_prefix   = local.name_prefix
  aws_region    = local.aws_region
  resource_tags = var.resource_tags
}

module "airflow_ecs_cluster" {
  source                   = "../../../modules/aws/ecs-cluster"
  name_prefix              = local.name_prefix
  aws_region               = var.aws_region
}

module "airflow_ecs_task" {
  source                   = "../../../modules/aws/ecs-task"
  name_prefix              = local.name_prefix
  aws_region               = var.aws_region
  use_fargate              = true
  ecs_cluster_name         = module.airflow_ecs_cluster.ecs_cluster_name
  container_image          = var.container_image
  container_num_cores      = var.container_num_cores
  container_ram_gb         = var.container_ram_gb
  admin_ports              = { "WebPortal" : 8080 }
  # app_ports                = { "WebPortal" : 8080 }
  vpc_id                   = local.vpc_id
  public_subnets           = local.public_subnets
  private_subnets          = local.private_subnets
  always_on                = true
  use_load_balancer        = true
}
