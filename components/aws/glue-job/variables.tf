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

variable "s3_script_path" {
  description = <<EOF
Full S3 path to the python Glue script. If `local_script_path` is also specified, the local
file will automatically be uploaded to the S3 path, replacing the existing file if
applicable.
EOF
  type        = string
  default     = null
}

variable "s3_source_bucket_name" {
  description = <<EOF
S3 source bucket for Glue transformation job. The glue job will automatically be granted
access to read and write from this bucket.
EOF
  type        = string
}

variable "s3_destination_bucket_name" {
  description = <<EOF
S3 destination bucket for Glue transformation job. The glue job will automatically be
granted access to read and write from this bucket.
EOF
  type        = string
}

variable "local_script_path" {
  description = <<EOF
Optional. Local path to the python Glue script. If this is not provided, the script file
will be assumed to already exist at the location specified in `s3_script_path`.
EOF
  type        = string
  default     = null
}

variable "use_spark" {
  description = "True to use 'pyspark' engine, otherwise 'python'."
  type        = bool
  default     = true
}
