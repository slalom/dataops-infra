################################################
### Standard variables for all Azure modules ###
################################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input. (Prefix counts towards 64-character max length for certain resource types.)"
  type        = string
}

variable "resource_tags" {
  description = "Standard `resource_tags` module input."
  type        = map(string)
}

########################################
### Custom variables for this module ###
########################################

variable "azure_location" {
  description = "The location the Storage Account will exist."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group to be created."
  type        = string
}
