variable "name_prefix" {}
variable "aws_region" { default = null }
variable "resource_tags" {
  type    = map
  default = {}
}
variable "disabled" {
  description = "As a workaround for unsupported 'count' feature in terraform modules, this switch can be used to disable the module entirely."
  default     = false
}
