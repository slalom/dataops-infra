variable "name_prefix" {}
variable "region" { description = "AWS region" }
variable "ec2_instance_type" { type = "string" }
variable "ec2_instance_storage_gb" { default = 100 }
variable "num_instances" { default = 1 }
variable "vpc_id" { type = "string" }
variable "subnet_ids" { type = "list" }
variable "default_cidr" { default = ["0.0.0.0/0"] }
variable "admin_cidr" { default = [] }
variable "use_https" { default = false }
variable "https_domain" { default = "" }
variable "ami_owner" { default = "amazon" }
variable "ami_name_filter" { type = "string" }
variable "is_windows" { default = false }
variable "admin_ports" {
  type    = "map"
  default = {}
}
variable "files" {
  default     = []
  description = "List of files to needed on the instance (e.g. 'http://url/to/remote/file', '/path/to/local/file', '/path/to/local/file:renamed')"
}
variable "app_ports" {
  type        = "map"
  description = "map of port descriptions to port numbers (e.g. 22) or ranges (e.g. '0:65535')"
  default     = { "SSH" : "22" }
}
