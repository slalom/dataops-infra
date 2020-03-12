variable "name_prefix" {
  type = string
}

variable "environment" {
  type = object({
    vpc_id          = string
    aws_region      = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}

variable "state_machine_definition" {
  type = string
}

variable "s3_bucket_name" {
  type = string
}

variable "resource_tags" {
  type    = map
  default = {}
}

variable "lambda_functions" {
  description = "Map of function names to ARNs"
  type        = map(string)
}
