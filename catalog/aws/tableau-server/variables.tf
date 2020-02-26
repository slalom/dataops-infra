variable "name_prefix" { type = string }
variable "environment" {
  type = object({
    vpc_id          = string
    aws_region      = list(string)
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "resource_tags" {
  type    = map
  default = {}
}
variable "ec2_instance_type" { default = "m4.4xlarge" }
variable "ec2_instance_storage_gb" { default = 100 }
variable "num_linux_instances" { default = 1 }
variable "num_windows_instances" { default = 0 }
variable "registration_file" { default = "../../.secrets/registration.json" }
variable "admin_cidr" { default = [] }
variable "default_cidr" { default = ["0.0.0.0/0"] }
variable "linux_use_https" { default = false }
variable "linux_https_domain" { default = "" }
variable "windows_use_https" { default = false }
variable "windows_https_domain" { default = "" }
