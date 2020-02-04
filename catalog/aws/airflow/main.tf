data "aws_region" "current" {}

locals {
  aws_region = var.aws_region != null ? var.aws_region : data.aws_region.current.name
}
module "airflow_vpc" {
  source      = "../../../modules/aws/vpc"
  name_prefix = var.name_prefix
}

module "airflow_ecs_cluster" {
  source                   = "../../../modules/aws/ecs-cluster"
  name_prefix              = var.name_prefix
  aws_region               = local.aws_region
}

module "airflow_ecs_task" {
  source                   = "../../../modules/aws/ecs-task"
  name_prefix              = var.name_prefix
  aws_region               = local.aws_region
  use_fargate              = true
  ecs_cluster_name         = module.airflow_ecs_cluster.ecs_cluster_name
  container_image          = var.container_image
  container_num_cores      = var.container_num_cores
  container_ram_gb         = var.container_ram_gb
  admin_ports              = { "WebPortal" : 8080 }
  # app_ports                = { "WebPortal" : 8080 }
  vpc_id                   = module.airflow_vpc.vpc_id
  subnets                  = module.airflow_vpc.public_subnet_ids
  always_on                = true
  use_load_balancer        = true
}
