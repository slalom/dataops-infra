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
  default = null
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
