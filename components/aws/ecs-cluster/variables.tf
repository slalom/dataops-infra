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

variable "ec2_instance_type" { default = "m4.xlarge" }
variable "ec2_instance_count" { default = 0 }
