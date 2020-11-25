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
variable "data_lake_name" {
  description = "The name of the Data Lake that will be created."
  type        = string
}

variable "data_lake_type" {
  description = "The type of Data Lake to be created.  Possible values are Gen1 or Gen2."
  type        = string
}

variable "storage_account_id" {
  description = "The ID for the Storage Account in which this Data Lake will be created."
  type        = string
}
