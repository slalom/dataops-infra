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
variable "data_lake_name" {
  description = "The name of the Data Lake that will be created."
  type        = string
}

variable "data_lake_type" {
  description = "The type of Data Lake to be created.  Possible values are Gen1 or Gen2."
  type        = string
}

# OPTIONAL
variable "azure_location" {
  description = "The location the Data Lake will exist."
  type        = string
  default     = ""
}

variable "resource_group_name" {
  description = "The name of the Resource Group which the Data Lake will be created within."
  type        = string
  default     = ""
}

variable "storage_account_id" {
  description = "The ID for the Storage Account in which this Data Lake will be created."
  type        = string
  default     = ""
}

variable "encryption_state" {
  description = "Defines whether exncryption is enabled on this Data Lake account. Possible values are Enabled or Disabled."
  type        = string
  default     = "Enabled"
}

variable "firewall_allow_azure_ips" {
  description = "Defines whether Azure Service IPs are allowed through the firewall. Possible values are Enabled and Disabled."
  type        = string
  default     = "Enabled"
}

variable "firewall_state" {
  description = "The state of the firewall for the Data Lake. Possible values are Enabled and Disabled."
  type        = string
  default     = "Enabled"
}
