variable "name_prefix" { type = string }
variable "resource_tags" {
  type    = map
  default = {}
}

# variable "secrets_file" {
#   description = "Input file (yaml or json) which contains the secrets to be uploaded."
#   default     = null
# }

variable "secrets_map" {
  description = <<EOF
A map between secret names and their locations.
The location can be:
 - ID of an existing Secrets Manager secret (`arn:aws:secretsmanager:...`)
 - String with the local secrets file name and property names separated by ':'."
EOF
  type        = map(string)
  default     = {}
}

variable "kms_key_id" {
  type    = string
  default = null
}
