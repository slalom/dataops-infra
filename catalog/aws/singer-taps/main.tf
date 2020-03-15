/*
* The Singer Taps platform is the open source stack which powers the [Stitcher](https://www.stitcher.com) ELT platform. For more information, see [singer.io](https://singer.io)
*
*/

data "aws_availability_zones" "az_list" {}

locals {
  tz_hour_offset = (
    contains(["PST"], var.scheduled_timezone) ? -8 :
    contains(["EST"], var.scheduled_timezone) ? -5 :
    contains(["UTC", "GMT"], var.scheduled_timezone) ? 0 :
    1 / 0 # ERROR: currently supported timezone code are: "UTC", "GMT", "EST", and "PST"
  )
  name_prefix = "${var.name_prefix}Tap-"
  container_image = coalesce(
    var.container_image, "slalomggp/singer:${var.taps[0].id}-to-${local.target.id}"
  )
  sync_commands = [
    for tap in var.taps :
    "s-tap sync ${tap.id} ${local.target.id}"
  ]
  container_command = (
    length(local.sync_commands) == 1 ? local.sync_commands[0] :
    chomp(coalesce(var.container_command,
      <<EOF
/bin/bash -c "${join(" && ", local.sync_commands)}"
EOF
    ))
  )
  target = (
    var.data_lake_type == "S3" ?
    {
      id = "s3-csv"
      settings = {
        # https://gist.github.com/aaronsteers/19eb4d6cba926327f8b25089cb79259b
        # Parse the S3 path into 'bucket' and 'key' values:
        s3_bucket = split("/", split("//", var.data_lake_storage_path)[1])[0]
        s3_key_prefix = join("/",
          [
            join("/", slice(
              split("/", split("//", var.data_lake_storage_path)[1]),
              1,
              length(split("/", split("//", var.data_lake_storage_path)[1]))
            )),
            replace(var.data_file_naming_scheme, "{file}", "")
          ]
        )
      }
      secrets = {
        # AWS creds secrets will be parsed from local env variables, provided by ECS Task Role
        # aws_access_key_id     = "../.secrets/aws-secrets-manager-secrets.yml:S3_CSV_aws_access_key_id"
        # aws_secret_access_key = "../.secrets/aws-secrets-manager-secrets.yml:S3_CSV_aws_secret_access_key"
      }
    } :
    var.target
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
      "TAP_CONFIG_DIR" : "${var.data_lake_metadata_path}/tap-snapshot-${local.unique_hash}",
      "TAP_STATE_FILE" : "${var.data_lake_storage_path}/${var.state_file_naming_scheme}",
    },
    {
      for k, v in var.taps[0].settings :
      "TAP_${upper(replace(var.taps[0].id, "-", "_"))}_${k}" => v
    },
    {
      for k, v in local.target.settings :
      "TARGET_${upper(replace(local.target.id, "-", "_"))}_${k}" => v
    }
  )
  environment_secrets = merge(
    {
      for k, v in var.taps[0].secrets :
      "TAP_${upper(replace(var.taps[0].id, "-", "_"))}_${k}" => v
    },
    {
      for k, v in local.target.secrets :
      "TARGET_${upper(replace(local.target.id, "-", "_"))}_${k}" => v
    }
  )
  schedules = [
    # Convert 4-digit time of day into cron. Cron tester: https://crontab.guru/
    for cron_expr in var.scheduled_sync_times :
    "cron(${
      tonumber(substr(cron_expr, 2, 2))
      } ${
      (24 + tonumber(substr(cron_expr, 0, 2)) - local.tz_hour_offset) % 24
    } * * ? *)"
  ]
}
