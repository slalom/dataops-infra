# Uncomment this to use an S3 backend in place of local state files:
# terraform {
#   backend "s3" {
#     bucket = "my-bucket-name"
#     key    = "infra/dataops-pkg-state"
#     region = "us-east-2"
#   }
# }

variable "project_shortname" { type = "string" }
variable "admin_email" { type = "string" }
variable "admin_name" { type = "string" }
variable "resource_tags" { default = {} }
variable "aws_region" { default = "us-east-2" }

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "my_AZs" {}
# data "local_file" "config_yml" { filename = "config.yml" }
# locals { config = yamldecode(data.local_file.config_yml.content) }

provider "aws" {
  region  = var.aws_region
  version = "~> 2.10"
}
