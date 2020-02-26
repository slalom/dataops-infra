variable "name_prefix" {}
variable "environment" {
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "resource_tags" {
  type    = map
  default = {}
}
variable "ssh_key_name" { type = string }
variable "ssh_private_key_filepath" { type = string }
variable "instance_type" { type = string }
variable "instance_storage_gb" { default = 100 }
variable "num_instances" { default = 1 }
variable "default_cidr" { default = ["0.0.0.0/0"] }
variable "admin_cidr" { default = [] }
variable "use_https" { default = false }
variable "https_domain" { default = "" }
variable "ami_owner" { default = "amazon" }
variable "ami_name_filter" { type = string }
variable "is_windows" { default = false }
variable "admin_ports" {
  type    = map
  default = {}
}
variable "file_resources" {
  default     = []
  description = "List of files to needed on the instance (e.g. 'http://url/to/remote/file', '/path/to/local/file', '/path/to/local/file:renamed')"
}
variable "app_ports" {
  type        = map
  description = "map of port descriptions to port numbers (e.g. 22) or ranges (e.g. '0:65535')"
  default     = { "SSH" : "22" }
}
