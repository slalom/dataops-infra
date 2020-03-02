variable "name_prefix" { type = string }
variable "resource_tags" {
  type    = map
  default = {}
}

variable "secrets_file" {
  description = "Input file (yaml or json) which contains the secrets to be uploaded."
  default     = null
}

variable "secrets_file_map" {
  description = "A map of secret names to their property names in the secrets file."
  type        = map(string)
  default     = {}
}

variable "kms_key_id" {
  type    = string
  default = null
}
