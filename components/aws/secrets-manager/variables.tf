variable "name_prefix" {
  description = "Common variable: the name prefix to use in all created resources."
  type        = string
}
variable "resource_tags" {
  description = "Common variable: the resource tags to use in all created resources."
  type        = map
}

variable "secrets_map" {
  description = <<EOF
A map between secret names and their locations.

The location can be:

  - ID of an existing Secrets Manager secret (`arn:aws:secretsmanager:...`)<br>
  - String with the local secrets file name and property names separated by `:` (`path/to/file.yml:my_key_name`)."

EOF
  type        = map(string)
  default     = {}
}

variable "kms_key_id" {
  description = "Optional. A valid KMS key ID to use for encrypting the secret values. If omitted, the default KMS key will be applied."
  # type        = string
  default = null
}
