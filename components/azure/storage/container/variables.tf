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

# REQUIRED
variable "storage_account_name" {
  description = "The name of the Storage Account the Storage Container(s) will be created under."
  type        = string
}

variable "container_names" {
  description = "Names of Storage Containers to be created."
  type        = list(string)
  default     = []
}

# OPTIONAL WITH BUILT-IN DEFAULTS
variable "container_access_type" {
  description = "The access level configured for the Storage Container(s). Possible values are blob, container or private."
  type        = string
  default     = "private"
}
