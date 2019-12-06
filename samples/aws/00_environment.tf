# Uncomment this to use an S3 backend in place of local state files:
# terraform {
#   backend "s3" {
#     bucket = "my-bucket-name"
#     key    = "infra/dataops-pkg-state"
#     region = "us-east-2"
#   }
# }

data "local_file" "config_yml" { filename = "${path.module}/../../config.yml" }

locals {
  config = yamldecode(data.local_file.config_yml.content)
  project_shortname = local.config["project_shortname"]
  aws_region = local.config["aws_region"]
  name_prefix = "${local.project_shortname}-"
}

# variable "project_shortname" { default = "TestProject" }
variable "admin_email" { default = "test-user@noreply.com" }
variable "admin_name" { default = "Test User (OK to Delete)" }
variable "resource_tags" { default = {} }

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "my_AZs" {}

provider "aws" {
  region  = local.aws_region
  version = "~> 2.10"
}
