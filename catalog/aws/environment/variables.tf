##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input."
  type        = string
}
variable "environment" {
  description = "Standard `environment` module input. (Ignored for the `environment` module.)"
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
  description = "Optional, used for multi-region deployments. Overrides the contextual AWS region with the region code provided."
  default     = null
}
variable "disabled" {
  description = "As a workaround for unsupported 'count' feature in terraform modules, this switch can be used to disable the module entirely."
  default     = false
}
variable "secrets_folder" {
  description = "Path to the secrets folder (used when initializing the AWS provider.)"
  type        = string
}
variable "aws_profile" {
  description = "The name of the AWS profile to use. Optional unless set at the main AWS provider level, in which case it is required."
  type        = string
  default     = null
}
