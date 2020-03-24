##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input."
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
