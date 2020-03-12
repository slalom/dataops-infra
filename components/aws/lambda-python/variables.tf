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

variable "runtime" { default = "python3.8" }
variable "pip_path" { default = "pip3" }
variable "timeout_seconds" { default = 60 * 5 }
variable "lambda_source_folder" {
  description = "Local path to a folder containing the lambda source code"
  type        = string
  default     = "resources/fn_log"
}
variable "upload_to_s3" { type = bool }
variable "upload_to_s3_path" {
  description = <<EOF
S3 Path to where the source code zip should be uploaded.
Use in combination with: `upload_to_s3 = true`
EOF
  type        = string
  default     = null
}
variable "functions" {
  description = <<EOF
A map of function names to create and an object with properties describing the function.

Example:
  functions = [
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
  type = list(object({
    function_name = string
    s3_bucket     = string
    s3_path       = string
  }))
  default = []
}
