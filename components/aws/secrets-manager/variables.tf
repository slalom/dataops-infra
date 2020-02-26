variable "name_prefix" { type = string }
variable "resource_tags" {
  type    = map
  default = {}
}

variable "secrets_source_file_path" {
  default = null
}

variable "kms_key_id" {
  type    = string
  default = null
}

variable "secrets_names" {
  type    = set(string)
  default = []
}
