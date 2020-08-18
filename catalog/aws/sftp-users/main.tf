/*
* Automates the management of SFTP user accounts on the AWS Transfer Service. AWS Transfer Service
* provides an SFTP interface on top of existing S3 storage resources.
*
* * Designed to be used in combination with the `aws/sftp` module.
*
*/

data "aws_s3_bucket" "data_bucket" { bucket = var.data_bucket }

locals {
  group_names = toset(
    flatten([
      keys(var.group_permissions),
      flatten(values(var.user_groups))
    ])
  )
}

resource "aws_transfer_user" "sftp_users" {
  for_each  = var.users
  user_name = each.value
  server_id = var.sftp_server_id
  role      = aws_iam_role.sftp_iam_user_roles[each.value].arn
}

resource "aws_transfer_ssh_key" "new_user_ssh_keys" {
  for_each   = var.users
  server_id  = var.sftp_server_id
  user_name  = each.value
  body       = file(module.ssh_key_pair.public_key_filename) # The public key portion of an SSH key pair.
  depends_on = [module.ssh_key_pair]
}

module "ssh_key_pair" {
  for_each = var.users
  source                = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=master"
  namespace             = var.name_prefix
  stage                 = "stfp"
  name                  = each.value
  ssh_public_key_path   = var.secrets_folder
  generate_ssh_key      = "true"
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
}
