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
variable "azure_location" {
  description = "The location the Storage Account will exist."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the Resource Group which the Storage Account will be created within."
  type        = string
}

variable "storage_account_name" {
  description = "The name of the Storage Account to be created."
  type        = string
}

variable "account_tier" {
  description = "Defines the tier to use for this Storage Account."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "The type of replication to use for this Storage Account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  type        = string
  default     = "GZRS" # For protection against regional disasters, Microsoft recommends using geo-zone-redundant storage (GZRS), which uses ZRS in the primary region and also geo-replicates your data to a secondary region.
}

# OPTIONAL WITH BUILT-IN DEFAULTS
variable "account_kind" {
  description = "The kind of Storage Account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2."
  type        = string
  default     = "StorageV2"
}

variable "access_tier" {
  description = "The access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool."
  type        = string
  default     = "Hot"
}

variable "enable_https_traffic_only" {
   description = "Boolean flag which forces HTTPS if enabled."
   type        = bool
   default     = true
}

variable "allow_blob_public_access" {
   description = "Allow or disallow public access to all Blobs or Containers in the Storage Account."
   type        = bool
   default     = false
}

variable "is_hns_enabled" {
  description = "Defines whether Hierarchical Namespace is enabled. Typically used with Azure Data Lake Storage Gen 2."
  type        = bool
  default     = true
}
