/*
* The Singer Taps platform is the open source stack which powers the [Stitcher](https://www.stitcher.com) EL platform. For more information, see [singer.io](https://singer.io)
*
*/

data "aws_availability_zones" "az_list" {}

locals {
  tz_hour_offset = (
    contains(["PST"], var.scheduled_timezone) ? -8 :
    contains(["PDT"], var.scheduled_timezone) ? -7 :
    contains(["MST"], var.scheduled_timezone) ? -7 :
    contains(["CST"], var.scheduled_timezone) ? -6 :
    contains(["EST"], var.scheduled_timezone) ? -5 :
    contains(["UTC", "GMT"], var.scheduled_timezone) ? 0 :
    1 / 0 # ERROR: currently supported timezone code are: UTC, MST, GMT, CST, EST, PST and PDT
  )
  name_prefix = "${var.name_prefix}Tap-"
  sync_commands = [
    for tap in var.taps :
    "tapdance sync ${tap.id} ${local.target.id} ${join(" ", var.container_args)}"
  ]
  container_images = [
    for tap in var.taps :
    coalesce(
      var.container_image_override,
      "dataopstk/tapdance:${lookup(tap.settings, "EXE", replace(tap.id, "tap-", ""))}-to-${lookup(local.target.settings, "EXE", replace(local.target.id, "target-", ""))}${var.container_image_suffix}"
    )
  ]
  default_target_def = {
    id = "s3-csv"
    settings = {
      s3_bucket     = local.data_lake_storage_bucket
      s3_key_prefix = local.data_lake_storage_key_prefix
    }
    secrets = {}
  }
  target = var.data_lake_type != "S3" || var.target != null ? var.target : local.default_target_def
  tap_env_prefix = [
    for tap in var.taps :
    "TAP_${replace(upper(tap.name, "-", "_"))}_"
  ]
  target_env_prefix = "TARGET_${replace(upper(var.target.name, "-", "_"))}_"
}

module "ecs_cluster" {
  source        = "../../../components/aws/ecs-cluster"
  name_prefix   = local.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags
}

module "ecs_tap_sync_task" {
  count               = length(var.taps)
  source              = "../../../components/aws/ecs-task"
  name_prefix         = "${local.name_prefix}sync-"
  environment         = var.environment
  resource_tags       = var.resource_tags
  ecs_cluster_name    = module.ecs_cluster.ecs_cluster_name
  container_image     = local.container_images[count.index]
  container_command   = local.sync_commands[count.index]
  container_ram_gb    = var.container_ram_gb
  container_num_cores = var.container_num_cores
  use_private_subnet  = var.use_private_subnet
  use_fargate         = true
  environment_vars = merge(
    {
      TAP_CONFIG_DIR                                     = "${var.data_lake_metadata_path}/tap-snapshot-${local.unique_hash}",
      TAP_STATE_FILE                                     = "${coalesce(var.data_lake_storage_path, var.data_lake_metadata_path)}/${var.state_file_naming_scheme}",
      PIPELINE_VERSION_NUMBER                            = var.pipeline_version_number
      "${local.tap_env_prefix[count.index]}_CONFIG_FILE" = "False" # Config will be passed via env vars
      "${local.target_env_prefix}_CONFIG_FILE"           = "False" # Config will be passed via env vars
    },
    {
      for k, v in var.taps[count.index].settings :
      "${local.tap_env_prefix[count.index]}_${k}" => v
    },
    {
      for k, v in local.target.settings :
      "${local.target_env_prefix}_${k}" => v
    }
  )
  environment_secrets = merge(
    {
      for k, v in var.taps[count.index].secrets :
      "${local.tap_env_prefix[count.index]}_${k}" => length(split(v, ":")) > 1 ? v : "${v}:${k}"
    },
    {
      for k, v in local.target.secrets :
      "${local.target_env_prefix}_${k}" => length(split(v, ":")) > 1 ? v : "${v}:${k}"
    }
  )
  schedules = [
    # Converts 4-digit time of day into cron. https://crontab.guru/
    for cron_expr in var.taps[count.index].schedule :
    "cron(${
      tonumber(substr(cron_expr, 2, 2))
      } ${
      (24 + tonumber(substr(cron_expr, 0, 2)) - local.tz_hour_offset) % 24
    } * * ? *)"
  ]
}
