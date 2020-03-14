##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input."
  type        = string
}
variable "environment" {
  description = "Standard `environment` module input."
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "resource_tags" {
  description = "Standard `resource_tags` module input."
  type        = map(string)
}

########################################
### Custom variables for this module ###
########################################

variable "ec2_instance_type" { default = "m4.4xlarge" }
variable "ec2_instance_storage_gb" { default = 100 }
variable "num_linux_instances" { default = 1 }
variable "num_windows_instances" { default = 0 }
variable "registration_file" { default = "../../.secrets/registration.json" }
variable "admin_cidr" { default = [] }
variable "app_cidr" { default = ["0.0.0.0/0"] }
variable "linux_use_https" { default = false }
variable "linux_https_domain" { default = "" }
variable "windows_use_https" { default = false }
variable "windows_https_domain" { default = "" }
