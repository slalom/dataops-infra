/*
* The Singer Taps platform is the open source stack which powers the [Stitcher](https://www.stitcher.com) EL platform. For more information, see [singer.io](https://singer.io)
*
*/

# Timezone math:
locals {
  tz_hour_offset = (
    contains(["PST"], var.scheduled_timezone) ? -8 :
    contains(["PDT"], var.scheduled_timezone) ? -7 :
    contains(["MST"], var.scheduled_timezone) ? -7 :
    contains(["CST"], var.scheduled_timezone) ? -6 :
    contains(["EST"], var.scheduled_timezone) ? -5 :
    contains(["UTC", "GMT"], var.scheduled_timezone) ? 0 :
    1 / 0
    # ERROR: currently supported timezone code are: UTC, MST, GMT, CST, EST, PST and PDT
  )
}

# Target config:
locals {
  default_target_def = {
    id = "s3-csv"
    settings = {
      s3_bucket     = local.data_lake_storage_bucket
      s3_key_prefix = local.data_lake_storage_key_prefix
    }
    secrets = {}
  }
  target            = var.data_lake_type != "S3" || var.target != null ? var.target : local.default_target_def
  target_env_prefix = "TARGET_${replace(upper(local.target.id), "-", "_")}_"
}

# Tap config:
locals {
  name_prefix = "${var.name_prefix}Tap-"
  tap_env_prefix = [
    for tap in var.taps :
    "TAP_${replace(upper(tap.name), "-", "_")}_"
  ]
  taps_specs = [
    for tap in var.taps :
    {
      id           = tap.id
      name         = coalesce(lookup(tap, "name", null), tap.id) # default to `id` if `name` not provided.
      schedule     = coalesce(lookup(tap, "schedule", null), []) # default to no schedule ([])
      settings     = tap.settings
      secrets      = tap.secrets
      sync_command = "tapdance sync ${tap.name} ${local.target.id} ${join(" ", var.container_args)}"
      image = coalesce(
        var.container_image_override,
        "dataopstk/tapdance:${tap.id}-to-${local.target.id}${var.container_image_suffix}"
      )
    }
  ]
}

module "ecs_cluster" {
  source        = "../../../components/aws/ecs-cluster"
  name_prefix   = local.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags
}

module "ecs_tap_sync_task" {
  count                = length(local.taps_specs)
  source               = "../../../components/aws/ecs-task"
  name_prefix          = "${local.name_prefix}task${count.index}-"
  environment          = var.environment
  resource_tags        = var.resource_tags
  ecs_cluster_name     = module.ecs_cluster.ecs_cluster_name
  container_image      = local.taps_specs[count.index].image
  container_command    = local.taps_specs[count.index].sync_command
  container_ram_gb     = var.container_ram_gb
  container_num_cores  = var.container_num_cores
  use_private_subnet   = var.use_private_subnet
  use_fargate          = true
  permitted_s3_buckets = local.needed_s3_buckets
  environment_vars = merge(
    {
      TAP_CONFIG_DIR                                    = "${var.data_lake_metadata_path}/tap-snapshot-${local.unique_suffix}",
      TAP_STATE_FILE                                    = "${coalesce(var.data_lake_storage_path, var.data_lake_metadata_path)}/${var.state_file_naming_scheme}",
      PIPELINE_VERSION_NUMBER                           = var.pipeline_version_number
      "${local.tap_env_prefix[count.index]}CONFIG_FILE" = "False" # Config will be passed via env vars
      "${local.target_env_prefix}CONFIG_FILE"           = "False" # Config will be passed via env vars
    },
    var.data_lake_logging_path == null ? {} : {
      TAP_LOG_DIR = "${var.data_lake_logging_path}/tap-${local.taps_specs[count.index].name}/"
    },
    {
      for k, v in local.taps_specs[count.index].settings :
      "${local.tap_env_prefix[count.index]}${k}" => v
    },
    {
      for k, v in local.target.settings :
      "${local.target_env_prefix}${k}" => v
    }
  )
  environment_secrets = merge(
    {
      for k, v in local.taps_specs[count.index].secrets :
      "${local.tap_env_prefix[count.index]}${k}" => length(split(":", v)) > 1 ? v : "${v}:${k}"
    },
    {
      for k, v in local.target.secrets :
      "${local.target_env_prefix}${k}" => length(split(":", v)) > 1 ? v : "${v}:${k}"
    }
  )
}
