variable "name_prefix" { type = string }
variable "environment" {
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "data_bucket_override" {
  description = "Optionally, you can override the default data bucket with a bucket that already exists."
  type        = string
  default     = null
}
variable "resource_tags" {
  type    = map
  default = {}
}
variable "lambda_python_source" {
  description = "Local path to a folder containing the lambda source code (e.g. 'resources/fn_log')"
  type        = string
  default     = null
}
# variable "lambda_python_dependency_urls" {
#   type    = map(string)
#   default = {}
# }
variable "s3_triggers" {
  description = <<EOF
List of S3 triggers objects, for example:
[{
  function_name       = "fn_log"
  triggering_path     = "*"
  function_handler    = "main.lambda_handler"
  environment_vars    = {}
  environment_secrets = {}
}]
EOF
  type = map(object({
    # function_name       = string
    triggering_path     = string
    function_handler    = string
    environment_vars    = map(string)
    environment_secrets = map(string)
  }))
  default = {}
}
