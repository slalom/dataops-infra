##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input. (Prefix counts towards 64-character max length for certain resource types.)"
  type        = string
}
variable "environment" {
  description = "Standard `environment` module input."
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "resource_tags" {
  description = "Standard `resource_tags` module input."
  type        = map(string)
}

########################################
### Custom variables for this module ###
########################################

variable "data_bucket" {
  description = "The S3 bucket to connect to via SFTP."
  type        = string
  default     = null
}
variable "sftp_server_id" {
  description = "The ID of the AWS Transfer Server for SFTP connections."
  type        = string
}
variable "secrets_folder" {
  description = "A relative or absolute path of the folder in which to store key files."
  type        = string
}
variable "group_permissions" {
  description = <<EOF
Mapping of group names to list of objects containing the applicable permissions.

Example:
  group_permissions = {
    uploaders = [
      {
        path  = "data/uploads/"
        read  = true
        write = true
      }
    ]
    global_readers = [
      {
        path  = "/"
        read  = true
        write = false
      }
    ]
    global_writers = [
      {
        path  = "/"
        read  = true
        write = true
      }
    ]
  }
EOF
  type = map(list(object({
    path  = string
    read  = bool
    write = bool
  })))
  default = {}
}
variable "users" {
  description = "A set (or unique list) of user IDs."
  type        = set(string)
  default     = ["ajsteers"]
}
variable "user_groups" {
  description = "A mapping of user IDs to group name."
  type        = map(list(string))
  default = {
    ajsteers = ["global_reader", "uploader"]
  }
}
# variable "admin_keybase_id" {
#   description = <<EOF
# The default keybase.io user ID to use for PGP password encryption.

# If you do not yet have keybase ID, please install Keybase and then use Keybase to publish a new PGP key.

# To install Keybase:
#  - Windows Users: choco install keybase
#  - MacOSX Users:  brew cask install keybase

# To generate and publish a PGP key:
#  > keybase pgp gen
# EOF
# }
