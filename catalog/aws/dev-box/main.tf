/*
* The Singer Taps platform is the open source stack which powers the [Stitcher](https://www.stitcher.com) ELT platform. For more information, see [singer.io](https://singer.io)
*
*/

data "aws_availability_zones" "az_list" {}

locals {
  name_prefix         = "${var.name_prefix}devbox-"
  # container_command = ()
  ssh_public_key_base64 = filebase64(var.ssh_public_key_filepath)
}

module "ecs_dev_box_cluster" {
  source        = "../../../components/aws/ecs-cluster"
  name_prefix   = local.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags
}

module "ecs_dev_box_task" {
  # TODO: use for_each to run jobs in parallel when the feature launches
  # for_each            = var.taps
  source              = "../../../components/aws/ecs-task"
  name_prefix         = local.name_prefix
  environment         = var.environment
  resource_tags       = var.resource_tags
  ecs_cluster_name    = module.ecs_dev_box_cluster.ecs_cluster_name
  container_image     = module.ecr_image.ecr_image_url_and_tag
  container_ram_gb    = var.container_ram_gb
  container_num_cores = var.container_num_cores
  use_private_subnet  = var.use_private_subnet
  use_fargate         = true
  always_on           = true
  environment_vars = merge(var.settings, {
    SSH_PUBLIC_KEY_BASE64 = local.ssh_public_key_base64
  })
  environment_secrets = var.secrets
  app_ports=["22"]
  admin_ports=["22"]
}

module "ecr_image" {
  # TODO: use for_each to run jobs in parallel when the feature launches
  # for_each            = var.taps
  source               = "../../../components/aws/ecr-image"
  name_prefix          = local.name_prefix
  environment          = var.environment
  resource_tags        = var.resource_tags
  aws_credentials_file = var.aws_credentials_file

  repository_name      = "devbox"
  tag                  = "latest"
  source_image_path    = "${path.module}/resources"
  build_args = {
    source_image = var.source_image
  }
}
