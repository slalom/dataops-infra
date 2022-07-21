variable "tap_env_prefix" {
  description = "Name to be used for object creation"
  type        = string
}

variable "bucket_subdirectory" {
  description = "The s3 subdirectory."
  type        = string
}

variable "logging_bucket_arn" {
  description = "The s3 bucket where metrics will be stored."
  type        = string
}

