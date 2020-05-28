tvariable "name_prefix" { type = string }
variable "data_bucket" { type = string }
variable "resource_tags" { type = map(string) }
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
  descrption = "A mapping of user IDs to group name."
  type       = map(list(string))
  default = {
    ajsteers = ["global_reader", "uploader"]
  }
}
variable "admin_keybase_id" {
  description = <<EOF
The default keybase.io user ID to use for PGP password encryption.

If you do not yet have keybase ID, please install Keybase and then use Keybase to publish a new PGP key.

To install Keybase:
 - Windows Users: choco install keybase
 - MacOSX Users:  brew cask install keybase

To generate and publish a PGP key:
 > keybase pgp gen
EOF
}
