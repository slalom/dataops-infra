data "aws_availability_zones" "az_list" {}
data "aws_region" "current" {}

locals {
  name_prefix = "${var.name_prefix}DBT-"
  aws_region  = coalesce(var.aws_region, data.aws_region.current.name)
  admin_cidr  = var.admin_cidr
  admin_ports = ["8080", "10000"]
  tz_hour_offset = (
    contains(["PST", "Pacific"], var.scheduled_timezone) ? -8 : 0
  )
  vpc_id          = coalesce(var.vpc_id, module.vpc.vpc_id)
  public_subnets  = coalesce(var.public_subnets, module.vpc.public_subnets)
  private_subnets = coalesce(var.private_subnets, module.vpc.private_subnets)
  create_vpc      = var.vpc_id == null && var.private_subnets == null && var.public_subnets == null
}components/

module "vpc" {
  source        = "../../../modules/aws/vpc"
  disabled      = local.create_vpc ? false : true
  name_prefix   = local.name_prefix
  aws_region    = local.aws_region
  resource_tags = var.resource_tags
}components/

module "ecs_cluster" {
  source        = "../../../modules/aws/ecs-cluster"
  name_prefix   = local.name_prefix
  aws_region    = local.aws_region
  resource_tags = var.resource_tags
}components/

module "ecs_task" {
  source              = "../../../modules/aws/ecs-task"
  name_prefix         = "${local.name_prefix}run-"
  aws_region          = local.aws_region
  resource_tags       = var.resource_tags
  ecs_cluster_name    = module.ecs_cluster.ecs_cluster_name
  vpc_id              = local.vpc_id
  public_subnets      = local.public_subnets
  private_subnets     = local.private_subnets
  container_image     = var.container_image
  container_ram_gb    = var.container_ram_gb
  container_num_cores = var.container_num_cores
  container_command   = var.dbt_run_command
  use_fargate         = true
  admin_ports         = local.admin_ports
  environment_vars    = var.environment_vars
  environment_secrets = var.environment_secrets
  schedules = flatten([
    var.scheduled_refresh_interval == null ? [] : ["rate(${var.scheduled_refresh_interval})"],
    [
      # Convert 4-digit time of day into cron. Cron tester: https://crontab.guru/
      for cron_expr in var.scheduled_refresh_times :
      "cron(${
        tonumber(substr(cron_expr, 2, 2))
        } ${
        (tonumber(substr(cron_expr, 0, 2)) + local.tz_hour_offset + 24) % 24
      } * * ? *)"
    ]
  ])
}
