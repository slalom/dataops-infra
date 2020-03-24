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

variable "state_machine_name" {
  description = "The name of the state machine to be created."
  type        = string
}

variable "state_machine_definition" {
  description = "The JSON definition of the state machine to be created."
  type        = string
}

variable "account_id" {
  # TODO: Deprecate if possible or detect dynamically.
  description = "The account ID to use on resource ARNs and IDs."
  type        = string
}
