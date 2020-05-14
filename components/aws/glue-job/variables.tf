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

variable "s3_script_bucket_name" {
  description = "S3 script bucket for Glue transformation job."
  type        = string
}

variable "s3_source_bucket_name" {
  description = "S3 source bucket for Glue transformation job."
  type        = string
}

variable "s3_destination_bucket_name" {
  description = "S3 destination bucket for Glue transformation job."
  type        = string
}

variable "local_script_path" {
  description = "Optional. If provided, the local script will automatically be uploaded to the remote bucket path. In not provided, will use s3_script_path instead."
  type        = string
  default     = null
}

variable "s3_script_path" {
  description = "Ignored if `local_script_path` is provided. Otherwise, the file at this path will be used for the Glue script."
  type        = string
  default     = null
}

variable "with_spark" {
  description = "(Default=True). True for standard PySpark Glue job. False for Python Shell."
  type        = bool
  default     = true
}
