/*
* The environment module sets up common infrastrcuture like VPCs and network subnets. The `envrionment` output
* from this module is designed to be passed easily to downstream modules, streamlining the reuse of these core components.
*
*
*/

locals {
  is_windows_host = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  user_home       = pathexpand("~")
  secrets_folder  = abspath(var.secrets_folder)
  aws_credentials_file = (
    fileexists("${local.secrets_folder}/aws-credentials") ?
    "${local.secrets_folder}/aws-credentials" : (
      fileexists("${local.secrets_folder}/credentials") ?
      "${local.secrets_folder}/credentials" : null
    )
  )
  aws_user_switch_cmd = (
    local.aws_credentials_file == null ? "n/a" : (
      local.is_windows_host ?
      "SET AWS_SHARED_CREDENTIALS_FILE=${local.aws_credentials_file}" :
      "export AWS_SHARED_CREDENTIALS_FILE=${local.aws_credentials_file}"
    )
  )
}

module "vpc" {
  source               = "../../../components/aws/vpc"
  name_prefix          = var.name_prefix
  aws_region           = var.aws_region
  resource_tags        = var.resource_tags
  aws_credentials_file = local.aws_credentials_file
  aws_profile          = var.aws_profile
}

resource "random_id" "suffix" { byte_length = 2 }

module "ssh_key_pair" {
  source                = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=master"
  namespace             = "${var.name_prefix}ssh-${lower(random_id.suffix.dec)}"
  stage                 = "prod"
  name                  = "keypair"
  ssh_public_key_path   = local.secrets_folder
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
  generate_ssh_key      = true
}
