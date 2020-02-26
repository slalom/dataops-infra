variable "name_prefix" { type = string }
variable "environment" {
  type = object({
    vpc_id          = string
    aws_region      = list(string)
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}
variable "resource_tags" { type = map(string) }
variable "runtime" { default = "python3.8" }
variable "pip_path" { default = "pip3" }
variable "timeout_seconds" { default = 60 * 5 }
variable "lambda_source_folder" {
  description = "Local path to a folder containing the lambda source code"
  type        = string
  default     = "resources/fn_log"
}
variable "s3_path_to_lambda_zip" {
  description = "S3 Path to where the source code zip should be uploaded."
  type        = string
}
# variable "dependency_urls" {
#   description = "If additional files should be packaged into the source code zip, please provide map of relative target paths to their respective download URLs."
#   type        = map(string)
#   default     = {}
# }
variable "s3_trigger_bucket" {
  type    = string
  default = null
}
variable "s3_triggers" {
  type = map(object({
    # function_name       = string
    triggering_path     = string
    function_handler    = string
    environment_vars    = map(string)
    environment_secrets = map(string)
  }))
  default = {
    "fn_log" = {
      # function_name       = "fn_log"
      triggering_path     = "*"
      function_handler    = "main.lambda_handler"
      environment_vars    = {}
      environment_secrets = {}
    }
  }
}
