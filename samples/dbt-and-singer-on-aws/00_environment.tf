# STANDARD ENVIRONMENT DEFINITION
# NO NEED TO MODIFY THIS FILE

data "local_file" "config_yml" { filename = "${path.module}/../infra-config.yml" }
locals {
  config            = yamldecode(data.local_file.config_yml.content)
  secrets_folder    = "${path.module}/../../.secrets"
  secrets_file_path = "${local.secrets_folder}/aws-secrets-manager-secrets.yml"
  project_shortname = local.config["project_shortname"]
  name_prefix       = "${local.project_shortname}-"
  aws_region        = local.config["aws_region"]
  resource_tags     = local.config["resource_tags"]
}

provider "aws" {
  version                 = "~> 2.10"
  region                  = local.aws_region
  shared_credentials_file = "${local.secrets_folder}/credentials"
  profile                 = "default"
}

output "env_summary" { value = module.env.summary }
module "env" {
  source         = "../../catalog/aws/environment"
  name_prefix    = local.name_prefix
  aws_region     = local.aws_region
  resource_tags  = local.resource_tags
  secrets_folder = local.secrets_folder
}
