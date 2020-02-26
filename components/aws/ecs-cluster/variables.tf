##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" { type = string }
variable "environment" {
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "resource_tags" {
  type    = map(string)
  default = {}
}

########################################
### Custom variables for this module ###
########################################

variable "ec2_instance_type" { default = "m4.xlarge" }
variable "ec2_instance_count" { default = 0 }
