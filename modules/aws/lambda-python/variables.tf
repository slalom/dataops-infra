variable "triggering_s3_paths" {
  description = "A list of strings representing which S3 paths should be listened to."
  type        = list(string)
}
variable "environment_vars" { type = map(string) }
variable "environment_secrets" { type = map(string) }
variable "runtime" { default = "python3.7" }
variable "additional_tool_urls" {
  description = "A map of destination paths to source URLs."
  type        = map(string)
}
variable "source_root" { type = string }
variable "build_root" { type = string }
variable "handler" {
  type    = string
  default = "main.main"
}
