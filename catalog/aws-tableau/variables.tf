variable "name_prefix" {}
variable "region" { description = "AWS region" }
variable "ec2_instance_type" { type = "string" }
variable "ec2_instance_storage_gb" { default = 100 }
variable "num_linux_instances" { default = 1 }
variable "num_windows_instances" { default = 0 }
variable "registration_file" { default = "secrets/registration.json" }
variable "vpc_id" { type = "string" }
variable "subnet_ids" { type = "list" }
variable "default_cidr" { default = ["0.0.0.0/0"] }
variable "admin_cidr" { default = [] }
variable "linux_use_https" { default = false }
variable "linux_https_domain" { default = "" }
variable "windows_use_https" { default = false }
variable "windows_https_domain" { default = "" }
