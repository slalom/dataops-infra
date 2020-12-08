/*
* DBT (Data Built Tool) is a CI/CD and DevOps-friendly platform for automating data transformations. More info at [www.getdbt.com](https://www.getdbt.com).
*
*
*/

locals {
  name_prefix = "${var.name_prefix}DBT-"
  admin_cidr  = var.admin_cidr
  admin_ports = ["8080", "10000"]
  tz_hour_offset = ([
    contains(["PST"], var.scheduled_timezone) ? -8 :
    contains(["PDT"], var.scheduled_timezone) ? -7 :
    contains(["MST"], var.scheduled_timezone) ? -7 :
    contains(["CST"], var.scheduled_timezone) ? -6 :
    contains(["EST"], var.scheduled_timezone) ? -5 :
    contains(["UTC", "GMT"], var.scheduled_timezone) ? 0 :
    1 / 0
    # ERROR: currently supported timezone code are: "UTC", "GMT", "EST", "PST" and "PDT"
  ])[0] # Terraform formatting bug workaround
}

module "ecs_cluster" {
  source        = "../../../components/aws/ecs-cluster"
  name_prefix   = local.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags
}

module "ecs_task" {
  source              = "../../../components/aws/ecs-task"
  name_prefix         = "${local.name_prefix}run-"
  environment         = var.environment
  resource_tags       = var.resource_tags
  ecs_cluster_name    = module.ecs_cluster.ecs_cluster_name
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
        (24 + tonumber(substr(cron_expr, 0, 2)) - local.tz_hour_offset) % 24
      } * * ? *)"
    ]
  ])
}
