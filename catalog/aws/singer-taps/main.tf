data "aws_availability_zones" "az_list" {}
data "aws_region" "current" {}

locals {
  tz_hour_offset = (
    contains(["PST", "Pacific"], var.scheduled_timezone) ? -8 : 0
  )
  name_prefix = "${var.name_prefix}Tap-"
  container_image = coalesce(
    var.container_image, "slalomggp/singer:${var.taps[0].id}-to-${var.target.id}"
  )
  sync_commands = [
    for tap in var.taps :
    "s-tap sync ${tap.id} ${var.target.id}"
  ]
  container_command = (
    length(local.sync_commands) == 1 ? local.sync_commands[0] :
    chomp(coalesce(var.container_command,
      <<EOF
/bin/bash -c "${join(" && ", local.sync_commands)}"
EOF
    ))
  )
}

module "ecs_cluster" {
  source        = "../../../components/aws/ecs-cluster"
  name_prefix   = local.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags
}

module "ecs_tap_sync_task" {
  # TODO: use for_each to run jobs in parallel when the feature launches
  # for_each            = var.taps
  source              = "../../../components/aws/ecs-task"
  name_prefix         = "${local.name_prefix}sync-"
  environment         = var.environment
  resource_tags       = var.resource_tags
  ecs_cluster_name    = module.ecs_cluster.ecs_cluster_name
  container_image     = local.container_image
  container_command   = local.container_command
  container_ram_gb    = var.container_ram_gb
  container_num_cores = var.container_num_cores
  use_fargate         = true
  environment_vars = merge(
    {
      "TAP_CONFIG_DIR" : "s3://${var.source_code_s3_bucket}/${var.source_code_s3_path}/tap-snapshot-${local.unique_hash}"
    },
    {
      for k, v in var.taps[0].settings :
      "TAP_${upper(replace(var.taps[0].id, "-", "_"))}_${k}" => v
    },
    {
      for k, v in var.target.settings :
      "TARGET_${upper(replace(var.target.id, "-", "_"))}_${k}" => v
    }
  )
  environment_secrets = merge(
    {
      for k, v in var.taps[0].secrets :
      "TAP_${upper(replace(var.taps[0].id, "-", "_"))}_${k}" => v
    },
    {
      for k, v in var.target.secrets :
      "TARGET_${upper(replace(var.target.id, "-", "_"))}_${k}" => v
    }
  )
  schedules = [
    # Convert 4-digit time of day into cron. Cron tester: https://crontab.guru/
    for cron_expr in var.scheduled_sync_times :
    "cron(${
      tonumber(substr(cron_expr, 2, 2))
      } ${
      (tonumber(substr(cron_expr, 0, 2)) + local.tz_hour_offset + 24) % 24
    } * * ? *)"
  ]
}
