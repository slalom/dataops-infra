data "aws_availability_zones" "az_list" {}

locals {
  project_shortname = substr(var.name_prefix, 0, length(var.name_prefix) - 1)
  admin_cidr        = var.admin_cidr
  default_cidr      = length(var.default_cidr) == 0 ? local.admin_cidr : var.default_cidr
  app_ports = {
    "HTTP/HTTPS" = "80"
    "SSL"        = "443"
  }
  admin_ports = {
    "Tableau Services Manager (TSM)" = "8850"
  }
}

module "vpc" {
  source      = "../../modules/aws/vpc"
  name_prefix = var.name_prefix
}

module "ecs_cluster" {
  source                      = "../../modules/aws/ecs"
  name_prefix                 = local.name_prefix
  fargate_container_ram_gb    = var.container_ram_gb
  fargate_container_num_cores = var.container_num_cores
  app_ports                   = local.app_ports
  admin_ports                 = local.admin_ports
  vpc_id                      = module.vpc.id
  subnet_ids                  = module.vpc.private_subnet_ids
  ecs_environment_secrets     = {}
  ecs_security_group          = ""
  container_image             = "${var.docker_image}:${var.docker_tag}"
  container_command_overrides = {
    "run"     = "run"
    "compile" = "compile"
    "seed"    = "seed"
  }
}

resource "aws_cloudwatch_event_rule" "daily_run_schedule" {
  name                = "dtb-daily-run-schedule"
  description         = "Daily Execution"
  schedule_expression = "cron(0 20 * * ? *)"
}

resource "aws_cloudwatch_event_target" "daily_run_task" {
  rule       = aws_cloudwatch_event_rule.daily_run_schedule.name
  arn        = module.ecs_cluster.cluster_arn
  role_arn   = module.ecs_cluster.ecs_task_role_arn
  ecs_target {
    task_definition_arn = var.event_target_ecs_target_task_definition_arn
    task_count          = 1
    launch_type         = "FARGATE"
    group               = "DBT-ECSTaskGroup-Daily"
    network_configuration {
      subnets          = var.subnet_ids
      security_groups  = [var.ecs_security_group]
      assign_public_ip = false
    }
  }
}
