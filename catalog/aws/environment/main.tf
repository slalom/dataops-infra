locals {
  is_windows_host = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  user_home       = pathexpand("~")
  secrets_folder  = abspath(var.secrets_folder)
  aws_creds_file  = "${local.secrets_folder}/credentials"
  aws_user_switch_cmd = (
    local.is_windows_host ?
    "SET AWS_SHARED_CREDENTIALS_FILE=${local.aws_creds_file}" :
    "EXPORT AWS_SHARED_CREDENTIALS_FILE=${local.aws_creds_file}"
  )
}

module "vpc" {
  source        = "../../../components/aws/vpc"
  name_prefix   = var.name_prefix
  aws_region    = var.aws_region
  resource_tags = var.resource_tags
}

module "ssh_key_pair" {
  source                = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=master"
  namespace             = "${var.name_prefix}ssh"
  stage                 = "prod"
  name                  = "keypair"
  ssh_public_key_path   = local.secrets_folder
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
  generate_ssh_key      = true
}
