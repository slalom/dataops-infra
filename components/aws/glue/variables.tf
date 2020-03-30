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

variable "s3_bucket_name" {
  description = "Bucket which contains training data, model output, etc."
  type        = string
}

variable "script_path" {
  description = "Path to Glue script."
  type        = string
}

variable "job_name" {
  description = "Name of the Glue job."
  type        = string
}

variable "job_type" {
  description = "Type of Glue job (Spark or Python Shell)."
  type        = string
}