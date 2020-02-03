##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" { type = string }
variable "aws_region" { default = null }
variable "resource_tags" {
  type    = map(string)
  default = {}
}

########################################
### Custom variables for this module ###
########################################

variable "min_ec2_instances" { default = 0 }
variable "max_ec2_instances" { default = 3 }
variable "ec2_instance_type" { default = "m4.xlarge" }
