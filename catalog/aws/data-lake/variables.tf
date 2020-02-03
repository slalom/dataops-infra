variable "name_prefix" { type = string }
variable "aws_region" { default = null }
variable "resource_tags" {
  type    = map
  default = {}
}
