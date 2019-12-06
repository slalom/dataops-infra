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
  config              = yamldecode(data.local_file.config_yml.content)
  project_shortname   = local.config["project_shortname"]
  project_description = contains(local.config, "project_description") ? local.config["project_description"] : local.config["project_description"]
  aws_region          = local.config["aws_region"]
  name_prefix         = "${local.project_shortname}-"
  admin_email         = contains(local.config, "admin_email") ? local.config["admin_email"] : "test-user@noreply.com"
  admin_name          = contains(local.config, "admin_name") ? local.config["admin_name"] : "Test (OK to Delete)"
  project_tags        = contains(local.config, "project_tags") ? local.config["project_tags"] : {}
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "my_AZs" {}

provider "aws" {
  region  = local.aws_region
  version = "~> 2.10"
}
