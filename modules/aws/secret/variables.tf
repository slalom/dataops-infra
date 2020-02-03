variable "resource_tags" {
  type    = map
  default = {}
}
variable "name" { type = "string" }
variable "secret_text" {
  default = null
}
variable "secret_encrypted" {
  default = null
}
variable "local_pgp_public_key" {
  type = "string"
}
variable "aws_secret_manager_arn" {
  type    = "string"
  default = null
}
variable "local_environment_variable_name" {
  type    = "string"
  default = null
}
variable "kms_key_id" {
  type    = "string"
  default = null
}
variable "tags" {
  type    = "map"
  default = {}
}
