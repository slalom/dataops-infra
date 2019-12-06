variable "name_prefix" {}
variable "app_ports" { default = ["8080"] }
variable "admin_cidr" { default = [] }
variable "default_cidr" { default = ["0.0.0.0/0"] }
