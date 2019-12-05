terraform {
  backend "s3" {
    bucket = "propensity-to-buy"
    key    = "infra/dataops-pkg-state"
    region = "us-east-2"
  }
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "my_AZs" {}
data "local_file" "config_yml" { filename = "config.yml" }
locals { config = yamldecode(data.local_file.config_yml.content) }

provider "aws" {
  region  = local.aws_region
  version = "~> 2.10"
}

variable "project_shortname" { type = "string" }
variable "admin_email" { type = "string" }
variable "admin_name" { type = "string" }
variable "resource_tags" { default = {} }
