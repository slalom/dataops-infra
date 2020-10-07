/*
* The `bestion-host` catalog module deploys an ECS-backed container which can be used to remotely test
* or develop using the native cloud environment.
*
* Applicable use cases include:
*
* - Debugging network firewall and routing rules
* - Debugging components which can only be run from whitelisted IP ranges
* - Offloading heavy processing from the developer's local laptop
* - Mitigating network relability issues when working from WiFi or home networks
*
*/

data "aws_availability_zones" "az_list" {}

locals {
  name_prefix = "${var.name_prefix}devbox-"
  # container_command = ()
  ssh_public_key_base64 = filebase64(var.ssh_public_key_filepath)
}

module "ecs_bastion_cluster" {
  source        = "../../../components/aws/ecs-cluster"
  name_prefix   = local.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags
}

module "ecs_bastion_task" {
  source              = "../../../components/aws/ecs-task"
  name_prefix         = local.name_prefix
  environment         = var.environment
  resource_tags       = var.resource_tags
  ecs_cluster_name    = module.ecs_bastion_cluster.ecs_cluster_name
  container_image     = var.custom_base_image == null ? var.standard_image : module.ecr_image[0].ecr_image_url_and_tag
  container_ram_gb    = var.container_ram_gb
  container_num_cores = var.container_num_cores
  use_private_subnet  = var.use_private_subnet
  use_fargate         = true
  always_on           = true
  environment_vars = merge(var.settings, {
    SSH_PUBLIC_KEY_BASE64 = local.ssh_public_key_base64
  })
  environment_secrets = var.secrets
  app_ports           = []
  admin_ports         = ["22"]
  admin_cidr          = var.admin_cidr
}

module "ecr_image" {
  count                = var.custom_base_image != null ? 1 : 0
  source               = "../../../components/aws/ecr-image"
  name_prefix          = local.name_prefix
  environment          = var.environment
  resource_tags        = var.resource_tags
  aws_credentials_file = var.aws_credentials_file

  repository_name   = "devbox"
  tag               = "latest"
  source_image_path = "${path.module}/resources"
  build_args = {
    source_image = var.custom_base_image
  }
}
