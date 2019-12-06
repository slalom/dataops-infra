# Uncomment this to use an S3 backend in place of local state files:
# terraform {
#   backend "s3" {
#     bucket = "my-bucket-name"
#     key    = "infra/dataops-pkg-state"
#     region = "us-east-2"
#   }
# }

variable "project_shortname" { default = "TestProject" }
variable "admin_email" { default = "test-user@noreply.com" }
variable "admin_name" { default = "Test User (OK to Delete)" }
variable "resource_tags" { default = {} }
variable "aws_region" { default = "us-east-2" }

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "my_AZs" {}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.10"
}
