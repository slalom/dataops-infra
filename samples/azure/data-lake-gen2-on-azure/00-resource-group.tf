################################
### CONFIGURE REQUIRED PATHS ###
################################

locals {
  root             = "../../../"                 # Path to root of repo
  yaml_config_path = "../azure-infra-config.yml" # Required settings
}

############################################
### STANDARD ENVIRONMENT DEFINITION      ###
### NO NEED TO MODIFY REMAINDER OF FILE  ###
############################################

data "local_file" "config_yml" { filename = local.yaml_config_path }
locals {
  config             = yamldecode(data.local_file.config_yml.content)
  project_shortname  = local.config["project_shortname"]
  azure_subscription = local.config["subscription_id"]
  azure_location     = local.config["azure_location"]
  name_prefix        = local.project_shortname
  resource_tags      = merge(local.config["resource_tags"], { project = local.project_shortname })
}

provider "azurerm" {
  version         = "=2.20.0"
  environment     = "public"
  subscription_id = local.azure_subscription

  features {}
}

output "resource_group_summary" { value = module.rg.summary }
module "rg" {
  source         = "../../../catalog/azure/resource-group"
  name_prefix    = local.name_prefix
  azure_location = local.azure_location
  resource_tags  = local.resource_tags

  # CONFIGURE HERE:
  resource_group_name = "test"
}
