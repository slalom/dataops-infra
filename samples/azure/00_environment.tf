data "local_file" "config_yml" { filename = "${path.module}/../config.yml" }

locals {
  config            = yamldecode(data.local_file.config_yml.content)
  project_shortname = local.config["project_shortname"]
  name_prefix       = "${local.project_shortname}-"
  region            = local.config["region"]
  project_tags      = local.config["project_tags"]
}

provider "azurerm" {
  version = "=1.38.0"
}

# Create a resource group
resource "azurerm_resource_group" "project_rg" {
  name     = local.project_shortname
  location = local.region
  tags     = local.project_tags
}
