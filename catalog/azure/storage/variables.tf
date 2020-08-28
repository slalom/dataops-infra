################################################
### Standard variables for all Azure modules ###
################################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input."
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
  description = "The name of the Storage Account to be created."
  type        = string
}

# OPTIONAL
variable "container_names" {
  description = "Names of Storage Containers to be created."
  type        = list(string)
  default     = []
}

variable "table_storage_names" {
  description = "Names of Tables to be created."
  type        = list(string)
  default     = []
}

variable "queue_storage_names" {
  description = "Names of Queues to be created."
  type        = list(string)
  default     = []
}

# OPTIONAL WITH BUILT-IN DEFAULTS
variable "container_access_type" {
  description = "The access level configured for the Storage Container(s). Possible values are blob, container or private."
  type        = string
  default     = "private"
}
