variable "name_prefix" { type = string }
variable "aws_region" { default = null }
variable "resource_tags" {
  type    = map
  default = {}
}
variable "disabled" {
  description = "As a workaround for unsupported 'count' feature in terraform modules, this switch can be used to disable the module entirely."
  default     = false
}
variable "secrets_folder" {
  type = string
}
variable "aws_profile" {
  description = "Optional, unless set at the main AWS provider level in which case it is required."
  type        = string
  default     = null
}
