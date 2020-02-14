data "aws_availability_zones" "az_list" {}
data "aws_region" "current" {}

locals {
  tz_hour_offset = (
    contains(["PST", "Pacific"], var.scheduled_timezone) ? -8 : 0
  )
  vpc_id     = coalesce(var.vpc_id, module.vpc.vpc_id)
  subnets    = coalesce(var.subnets, module.vpc.public_subnets)
  aws_region = coalesce(var.aws_region, data.aws_region.current.name)
  name_prefix = "${var.name_prefix}Tap-"
}

module "vpc" {
  source        = "../../../modules/aws/vpc"
  disabled      = local.create_vpc ? false : true
  name_prefix   = local.name_prefix
  aws_region    = local.aws_region
  resource_tags = var.resource_tags
}

module "ecs_cluster" {
  source        = "../../../modules/aws/ecs-cluster"
  name_prefix   = local.name_prefix
  aws_region    = var.aws_region
  resource_tags = var.resource_tags
}

module "ecs_tap_sync_task" {
  source              = "../../../modules/aws/ecs-task"
  name_prefix         = "${local.name_prefix}sync-"
  aws_region          = var.aws_region
  resource_tags       = var.resource_tags
  ecs_cluster_name    = module.ecs_cluster.ecs_cluster_name
  vpc_id              = local.vpc_id
  public_subnets      = local.subnets
  private_subnets     = local.subnets
  container_image     = var.container_image
  container_ram_gb    = var.container_ram_gb
  container_num_cores = var.container_num_cores
  container_command   = var.tap_sync_command
  use_fargate         = true
  environment_vars    = var.environment_vars
  environment_secrets = var.environment_secrets
  schedules = flatten([
    var.scheduled_sync_interval == null ? [] : ["rate(${var.scheduled_sync_interval})"],
    [
      # Convert 4-digit time of day into cron. Cron tester: https://crontab.guru/
      for cron_expr in var.scheduled_sync_times :
      "cron(${
        tonumber(substr(cron_expr, 2, 2))
        } ${
        (tonumber(substr(cron_expr, 0, 2)) + local.tz_hour_offset + 24) % 24
      } * * ? *)"
    ]
  ])
}
