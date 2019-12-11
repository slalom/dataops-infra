data "aws_availability_zones" "myAZs" {}

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
  container_image             = ""
  container_entrypoint        = ""
  container_run_command       = ""
}
