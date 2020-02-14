data "aws_availability_zones" "az_list" {}
data "aws_region" "current" {}

locals {
  name_prefix              = "${var.name_prefix}Tableau-"
  aws_region               = coalesce(var.aws_region, data.aws_region.current.name)
  admin_cidr               = var.admin_cidr
  default_cidr             = length(var.default_cidr) == 0 ? local.admin_cidr : var.default_cidr
  ssh_key_dir              = pathexpand("~/.ssh")
  ssh_public_key_filepath  = "${local.ssh_key_dir}/${lower(local.name_prefix)}prod-ec2keypair.pub"
  ssh_private_key_filepath = "${local.ssh_key_dir}/${lower(local.name_prefix)}prod-ec2keypair.pem"
  win_files = flatten([
    fileset(path.module, "resources/win/*"),
    fileset(path.module, "resources/*"),
    ["${var.registration_file}:registration.json"]
  ])
  lin_files = flatten([
    fileset(path.module, "resources/lin/*"),
    fileset(path.module, "resources/*"),
    ["${var.registration_file}:registration.json"]
  ])
  tableau_app_ports = {
    "HTTP/HTTPS" = "80"
    "SSL"        = "443"
  }
  tableau_admin_ports = {
    "Tableau Services Manager (TSM)"       = "8850"
    "PostgreSQL Database"                  = "8060:8061"
    "Tableau License Verification Service" = "27000:27009"
    "Tableau dynamic process mapping"      = "8000:9000"
  }
  vpc_id          = coalecse(var.vpc_id, module.vpc.vpc_id)
  public_subnets  = coalece(var.public_subnets, module.vpc.public_subnets)
  private_subnets = coalece(var.private_subnets, module.vpc.private_subnets)
}

resource "aws_key_pair" "mykey" {
  key_name   = "${local.name_prefix}ec2-keypair"
  public_key = file(local.ssh_public_key_filepath)
}

module "vpc" {
  source        = "../../../modules/aws/vpc"
  name_prefix   = local.name_prefix
  aws_region    = local.aws_region
  resource_tags = var.resource_tags
}

module "windows_tableau_servers" {
  source                   = "../../../modules/aws/ec2"
  is_windows               = true
  name_prefix              = "${local.name_prefix}win-"
  aws_region               = local.aws_region
  resource_tags            = var.resource_tags
  num_instances            = var.num_windows_instances
  instance_type            = var.ec2_instance_type
  instance_storage_gb      = var.ec2_instance_storage_gb
  ami_owner                = "amazon" # Canonical
  ami_name_filter          = "Windows_Server-2016-English-Full-Base-*"
  admin_ports              = merge(local.tableau_admin_ports, { "RDP" : 3389 })
  app_ports                = local.tableau_app_ports
  ssh_key_name             = aws_key_pair.mykey.key_name
  ssh_private_key_filepath = local.ssh_private_key_filepath
  vpc_id                   = local.vpc_id
  subnet_id                = coalescelist(local.public_subnets, [""])[0]
}

module "linux_tableau_servers" {
  source                   = "../../../modules/aws/ec2"
  name_prefix              = "${local.name_prefix}lin-"
  aws_region               = local.aws_region
  resource_tags            = var.resource_tags
  num_instances            = var.num_linux_instances
  instance_type            = var.ec2_instance_type
  instance_storage_gb      = var.ec2_instance_storage_gb
  ami_owner                = "099720109477" # Canonical
  ami_name_filter          = "ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"
  admin_ports              = merge(local.tableau_admin_ports, { "SSH" : 22 })
  app_ports                = local.tableau_app_ports
  ssh_key_name             = aws_key_pair.mykey.key_name
  ssh_private_key_filepath = local.ssh_private_key_filepath
  vpc_id                   = local.vpc_id
  subnet_id                = coalescelist(local.public_subnets, [""])[0]
}
