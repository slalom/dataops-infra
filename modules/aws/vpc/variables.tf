variable "name_prefix" {}
variable "aws_region" { default = null }
variable "app_ports" { default = ["8080"] }
variable "admin_cidr" { default = [] }
variable "default_cidr" { default = ["0.0.0.0/0"] }
variable "resource_tags" {
  type    = map
  default = {}
}
