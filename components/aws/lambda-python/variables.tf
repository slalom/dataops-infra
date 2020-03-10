variable "name_prefix" { type = string }
variable "environment" {
  type = object({
    vpc_id          = string
    aws_region      = string
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
  description = <<EOF
S3 Path to where the source code zip should be uploaded.
If omitted, zip file will be attached to the function directly.
EOF
  type        = string
  default     = null
}
variable "functions" {
  description = <<EOF
A map of function names to create and an object with properties describing the function.

Example:
  python_functions = [
    "fn_log" = {
      description = "Add an entry to the log whenever a file is created."
      handler     = "main.lambda_handler"
      environment = {}
      secrets     = {}
    }
  ]
EOF
  type = map(object({
    description = string
    handler     = string
    environment = map(string)
    secrets     = map(string)
  }))
  default = {
    "fn_log" = {
      description = "Add an entry to the log whenever a file is created."
      handler     = "main.lambda_handler"
      environment = {}
      secrets     = {}
    }
  }
}
variable "s3_triggers" {
  description = <<EOF
A list of objects describing the S3 trigger action.

Example:
  s3_triggers = [
    {
      function_name = "fn_log"
      s3_bucket     = "*"
      s3_path       = "*"
    }
  ]
EOF
  type = map(object({
    function_name = string
    s3_bucket     = string
    s3_path       = string
  }))
  default = {}
}
