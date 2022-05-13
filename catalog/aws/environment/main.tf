/*
* The environment module sets up common infrastrcuture like VPCs and network subnets. The `environment` output
* from this module is designed to be passed easily to downstream modules, streamlining the reuse of these core components.
*
*
*/

locals {
  is_windows_host      = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  user_home            = pathexpand("~")
  aws_credentials_file = abspath(var.aws_credentials_file)
  aws_creds_file_check = length(filemd5(local.aws_credentials_file)) # Check if missing AWS Credentials file
}

module "vpc" {
  source                  = "../../../components/aws/vpc"
  name_prefix             = var.name_prefix
  aws_region              = var.aws_region
  resource_tags           = var.resource_tags
  aws_credentials_file    = local.aws_credentials_file
  aws_profile             = var.aws_profile
  vpc_cidr                = var.vpc_cidr
  subnet_cidrs            = var.subnet_cidrs
  enable_internet_gateway = var.enable_internet_gateway
  enable_nat_gateway      = var.enable_nat_gateway
  enable_elastic_ip       = var.enable_elastic_ip
}
