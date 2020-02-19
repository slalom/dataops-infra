variable "requirements_txt" {
  description = "A string of line-separated python requirements in the style of a 'requirements.txt' file"
  default     = "slalom.dataops"
}

variable "triggering_s3_paths" {
  description = "A list of strings representing which S3 paths should be listened to."
  type        = list(string)
}

variable "environment_vars" { type = map(string) }
variable "environment_secrets" { type = map(string) }
