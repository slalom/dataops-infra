# To enable remote SSH admininstration of linux virtual machines, enable one of the
# following options and comment-out or delete the other.

# Optional A: Automatically create and upload a new SSH keypair (recommended)

module "admin_ssh_key_pair" {
  source                = "git::https://github.com/aaronsteers/terraform-aws-key-pair.git?ref=main"
  namespace             = lower(local.name_prefix)
  ssh_public_key_path   = abspath(local.secrets_folder)
  tags                  = local.resource_tags
  name                  = "aws-ssh-key"
  delimiter             = ""
  generate_ssh_key      = true
  private_key_extension = ".pem"
  public_key_extension  = ".pub"
}

# # Optional B: Import an existing SSH keypair (only if a specific key is required)
#
# resource "aws_key_pair" "admin_ssh_key_pair" {
#   key_name   = "${lower(local.name_prefix)}-aws-ssh-key"
#   public_key = file(local.public_key_filename)
# }
