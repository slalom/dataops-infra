# Uncomment this to use an S3 backend in place of local state files:
# terraform {
#   backend "s3" {
#     bucket = "my-bucket-name"
#     key    = "infra/dataops-pkg-state"
#     region = "us-east-2"
#   }
# }

data "local_file" "config_yml" { filename = "${path.module}/../config.yml" }
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "my_AZs" {}

locals {
  config            = yamldecode(data.local_file.config_yml.content)
  project_shortname = local.config["project_shortname"]
  name_prefix       = "${local.project_shortname}-"
  aws_region        = local.config["aws_region"]
  project_tags      = local.config["project_tags"]
}

provider "aws" {
  region  = local.aws_region
  version = "~> 2.10"
  profile = "f{local.project_shortname}-terraform"
}
