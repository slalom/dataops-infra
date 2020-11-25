##############################################
### Standard variables for all AWS modules ###
##############################################

variable "name_prefix" {
  description = "Standard `name_prefix` module input. (Prefix counts towards 64-character max length for certain resource types.)"
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

variable "glue_database_name" {
  description = "Name of the Glue catalog database."
  type        = string
}

variable "glue_crawler_name" {
  description = "Name of the Glue crawler."
  type        = string
}

variable "s3_target_bucket_name" {
  description = "S3 target bucket for Glue crawler."
  type        = string
}

variable "target_path" {
  description = "Path to crawler target file(s)."
  type        = string
}
