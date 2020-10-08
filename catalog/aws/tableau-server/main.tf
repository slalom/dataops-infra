/*
* This module securely deploys one or more Tableau Servers, which can then be used to host reports in production or POC environments.
* The module supports both Linux and Windows versions of the Tableau Server Software.
*
*/

locals {
  name_prefix = "${var.name_prefix}Tableau-"
  admin_cidr  = var.admin_cidr
  app_cidr    = length(var.app_cidr) == 0 ? local.admin_cidr : var.app_cidr
  ssh_key_dir = pathexpand("~/.ssh")
  win_files = [
    for file in flatten([
      fileset(abspath(path.module), "resources/win/*"),
      fileset(abspath(path.module), "resources/*"),
      ["${var.registration_file}::registration.json"]
    ]) :
    substr(file, 0, 4) == "http" ? file : "${abspath(path.module)}/${file}"
  ]
  lin_files = [
    for file in flatten([
      fileset(abspath(path.module), "resources/lin/*"),
      fileset(abspath(path.module), "resources/*"),
      ["${var.registration_file}::registration.json"]
    ]) :
    substr(file, 0, 4) == "http" ? file : "${abspath(path.module)}/${file}"
  ]
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
  # Allow cluster to communicate with itself on all ports.
  # At minimum, ports 8000:9000 are required.
  cluster_ports = merge(local.tableau_app_ports, local.tableau_admin_ports)
}

module "windows_tableau_servers" {
  source        = "../../../components/aws/ec2"
  name_prefix   = "${local.name_prefix}win-"
  environment   = var.environment
  resource_tags = var.resource_tags

  is_windows          = true
  num_instances       = var.num_windows_instances
  file_resources      = local.win_files
  instance_type       = var.ec2_instance_type
  instance_storage_gb = var.ec2_instance_storage_gb
  ami_owner           = "amazon" # Canonical
  ami_name_filter     = "Windows_Server-2016-English-Full-Base-*"

  use_private_subnets = var.use_private_subnets
  admin_ports         = merge(local.tableau_admin_ports, { "RDP" : 3389 })
  admin_cidr          = local.admin_cidr
  app_ports           = local.tableau_app_ports
  app_cidr            = local.app_cidr
  cluster_ports       = local.cluster_ports

  ssh_keypair_name         = var.ssh_keypair_name
  ssh_private_key_filepath = var.ssh_private_key_filepath
}

module "linux_tableau_servers" {
  source        = "../../../components/aws/ec2"
  name_prefix   = "${local.name_prefix}lin-"
  environment   = var.environment
  resource_tags = var.resource_tags

  num_instances       = var.num_linux_instances
  instance_type       = var.ec2_instance_type
  instance_storage_gb = var.ec2_instance_storage_gb
  ami_owner           = "099720109477" # Canonical
  ami_name_filter     = "ubuntu/images/hvm-ssd/ubuntu-*-18.04-amd64-server-*"
  file_resources      = local.lin_files

  use_private_subnets = var.use_private_subnets
  admin_ports         = merge(local.tableau_admin_ports, { "SSH" : 22 })
  admin_cidr          = local.admin_cidr
  app_ports           = local.tableau_app_ports
  app_cidr            = local.app_cidr
  cluster_ports       = local.cluster_ports

  ssh_keypair_name         = var.ssh_keypair_name
  ssh_private_key_filepath = var.ssh_private_key_filepath
}
