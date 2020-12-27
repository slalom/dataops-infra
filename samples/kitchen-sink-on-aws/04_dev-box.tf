# This Linux "dev box" in the cloud may be used as a bastion host to test and interact with resources
# which are in private subnets or which are firewalled to only communicate to the VPC's IP CIDR.

output "remote_dev_box_summary" { value = module.remote_dev_box.summary }
module "remote_dev_box" {
  source = "../../catalog/aws/bastion-host"
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/bastion-host?ref=main"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  ssh_public_key_filepath  = module.dev_box_ssh_key_pair.public_key_filename
  ssh_private_key_filepath = module.dev_box_ssh_key_pair.private_key_filename
  aws_credentials_file     = local.aws_credentials_file
  settings = {
    SAMPLE_ENV_VAR = "foo"
  }
  secrets    = {}
  depends_on = [module.dev_box_ssh_key_pair]
}

module "dev_box_ssh_key_pair" {
  source                = "git::https://github.com/cloudposse/terraform-aws-key-pair?ref=master"
  namespace             = lower(local.name_prefix)
  ssh_public_key_path   = abspath(local.secrets_folder)
  tags                  = local.resource_tags
  name                  = "dev-box-ssh"
  delimiter             = ""
  generate_ssh_key      = true
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
}
