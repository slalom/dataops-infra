data "aws_availability_zones" "myAZs" {}

resource "aws_key_pair" "mykey" {
  key_name   = "${var.name_prefix}ec2-keypair"
  public_key = file(local.ssh_public_key_filepath)
}

locals {
  project_shortname        = substr(var.name_prefix, 0, length(var.name_prefix) - 1)
  admin_cidr               = var.admin_cidr
  default_cidr             = length(var.default_cidr) == 0 ? local.admin_cidr : var.default_cidr
  ssh_key_dir              = pathexpand("~/.ssh")
  ssh_public_key_filepath  = "${local.ssh_key_dir}/${lower(var.name_prefix)}prod-ec2keypair.pub"
  ssh_private_key_filepath = "${local.ssh_key_dir}/${lower(var.name_prefix)}prod-ec2keypair.pem"
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
}

module "tableau_vpc" {
  source      = "../../modules/aws/vpc"
  name_prefix = var.name_prefix
}

module "windows_tableau_server" {
  source              = "../../modules/aws/ec2"
  name_prefix         = var.name_prefix
  aws_region          = var.aws_region
  num_instances       = var.num_windows_instances
  instance_type       = var.ec2_instance_type
  instance_storage_gb = var.ec2_instance_storage_gb
  ami_owner           = "amazon" # Canonical
  ami_name_filter     = "Windows_Server-2016-English-Full-Base-*"
  admin_ports         = merge(local.tableau_admin_ports, { "RDP" : 3389 })
  app_ports           = local.tableau_app_ports
  vpc_id              = module.tableau_vpc.vpc_id
  subnet_id           = module.tableau_vpc.private_subnet_ids[0]
  is_windows          = true
  # ssh_public_key_filepath  = local.ssh_public_key_filepath
  # ssh_private_key_filepath = local.ssh_private_key_filepath
  ssh_key_name             = aws_key_pair.mykey.key_name
  ssh_private_key_filepath = local.ssh_private_key_filepath
}

module "linux_tableau_server" {
  source              = "../../modules/aws/ec2"
  name_prefix         = var.name_prefix
  aws_region          = var.aws_region
  num_instances       = var.num_linux_instances
  instance_type       = var.ec2_instance_type
  instance_storage_gb = var.ec2_instance_storage_gb
  ami_owner           = "099720109477" # Canonical
  ami_name_filter     = "ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"
  admin_ports         = merge(local.tableau_admin_ports, { "SSH" : 22 })
  app_ports           = local.tableau_app_ports
  vpc_id              = module.tableau_vpc.vpc_id
  subnet_id           = module.tableau_vpc.private_subnet_ids[0]
  # ssh_public_key_filepath  = local.ssh_public_key_filepath
  # ssh_private_key_filepath = local.ssh_private_key_filepath
  ssh_key_name             = aws_key_pair.mykey.key_name
  ssh_private_key_filepath = local.ssh_private_key_filepath
}
