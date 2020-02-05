# STANDARD TERRAFORM ENVIRONMENT DEFINITION
# NO NEED TO MODIFY THIS FILE

data "local_file" "config_yml" { filename = "${path.module}/../config.yml" }
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "az_list" {}

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
  profile = "${local.project_shortname}-terraform"
}

module "vpc" {
  source        = "../../modules/aws/vpc"
  name_prefix   = local.name_prefix
  aws_region    = local.aws_region
  resource_tags = local.config["project_tags"]
}
