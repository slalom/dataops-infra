##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input. (Prefix counts towards 64-character max length for certain resource types.)"
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
  description = "Required. Specifies the AWS region."
  type        = string
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
variable "enable_internet_gateway" {
  description = <<EOF
Optional. Specifies if an Internet Gateway should be associated to the VPC. An Internet Gateway is required to receive
any type of incoming traffic over the internet.

Note:

- Most modules also supportthe variables `admin_cidr` (associated with `admin_ports`)
  and `app_cidr` (associated with `app_ports`).
- The `admin_cidr` and `app_cidr` variables can be leveraged to limit internet traffic only
  from specific sources.
EOF
  type        = bool
  default     = true
}

variable "enable_elastic_ip" {
    description = <<EOF
Disable the creation of Elastic IP.
EOF
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = <<EOF
Disable the creation of NAT gateway and route.
EOF
  type        = bool
  default     = true
}