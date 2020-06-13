##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input."
  type        = string
}
variable "environment" {
  description = "Standard `environment` module input. (Ignored for the `vpc` module.)"
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
  default = null
}
variable "resource_tags" {
  description = "Standard `resource_tags` module input."
  type        = map(string)
}

########################################
### Custom variables for this module ###
########################################

variable "aws_region" {
  description = "Optional. Overrides the AWS region, otherwise will use the AWS region provided from context."
  default     = null
}
variable "disabled" {
  description = "As a workaround for unsupported 'count' feature in terraform modules, this switch can be used to disable the module entirely."
  default     = false
}
variable "aws_credentials_file" {
  description = "Optional, unless set at the main AWS provider level in which case it is required."
  type        = string
  default     = null
}
variable "aws_profile" {
  description = "Optional, unless set at the main AWS provider level in which case it is required."
  type        = string
  default     = null
}
variable "vpc_cidr" {
  description = "Optional. The CIDR block to use for the VPC network."
  default     = "10.0.0.0/16"
}
variable "subnet_cidrs" {
  description = <<EOF
Optional. The CIDR blocks to use for the subnets.
The list should have the 2 public subnet cidrs first, followed by the 2 private subnet cidrs.
If omitted, the VPC CIDR block will be split evenly into 4 equally-sized subnets.
EOF
  type        = list(string)
  default     = null
}
