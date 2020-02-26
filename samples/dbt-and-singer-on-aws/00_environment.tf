# STANDARD TERRAFORM ENVIRONMENT DEFINITION
# NO NEED TO MODIFY THIS FILE

data "local_file" "config_yml" { filename = "${path.module}/../infra-config.yml" }
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "az_list" {}

locals {
  config            = yamldecode(data.local_file.config_yml.content)
  secrets_file_path = "${path.module}/../.secrets/aws-secrets-manager-secrets.yml"
  secrets_file      = fileexists(local.secrets_file_path) ? local.secrets_file : null
  project_shortname = local.config["project_shortname"]
  name_prefix       = "${local.project_shortname}-"
  aws_region        = local.config["aws_region"]
  resource_tags     = local.config["project_tags"]
}

provider "aws" {
  version                 = "~> 2.10"
  region                  = local.aws_region
  shared_credentials_file = "../../.secrets/credentials"
  profile                 = "${local.project_shortname}-terraform"
}

module "env" {
  # TODO: Revert to stable source
  source        = "../../catalog/aws/environment"
  name_prefix   = local.name_prefix
  aws_region    = local.aws_region
  resource_tags = local.config["project_tags"]
}
