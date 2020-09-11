################################
### CONFIGURE REQUIRED PATHS ###
################################

locals {
  root                 = "../.."                          # Path to root of repo
  yaml_config_path     = "../infra-config.yml"            # Required settings
  secrets_folder       = "../../.secrets"                 # Default secrets location
  aws_credentials_file = "../../.secrets/aws-credentials" # AWS Credentials
}

############################################
### STANDARD ENVIRONMENT DEFINITION      ###
### NO NEED TO MODIFY REMAINDER OF FILE  ###
############################################

data "local_file" "config_yml" { filename = local.yaml_config_path }
locals {
  config            = yamldecode(data.local_file.config_yml.content)
  project_shortname = local.config["project_shortname"]
  aws_region        = local.config["aws_region"]
  name_prefix       = "${local.project_shortname}-"
  #added for non-default credentials profiles
  aws_profile       = local.config["profile"]
  resource_tags     = merge(local.config["resource_tags"], { project = local.project_shortname })
}

provider "aws" {
  version                 = "~> 3.0"
  region                  = local.aws_region
  shared_credentials_file = local.aws_credentials_file
  #using the profile name from the local variables
  profile                 = local.aws_profile
}

output "env_summary" { value = module.env.summary }
module "env" {
  source               = "../../catalog/aws/environment"
  name_prefix          = local.name_prefix
  aws_region           = local.aws_region
  aws_credentials_file = local.aws_credentials_file
  resource_tags        = local.resource_tags
  aws_profile          = local.aws_profile
}

resource "null_resource" "secrets_folder_protection" {
  provisioner "local-exec" {
    interpreter = module.env.is_windows_host ? ["cmd", "/C"] : []
    # on_failure = continue
    command = (
      module.env.is_windows_host == false ? "chmod -R 700 ${local.secrets_folder}" : join(" && ", [
        "echo Orverriding permissions on ${local.secrets_folder} (running as %username%)...",
        "icacls ${local.secrets_folder} /grant:r %username%:(F) /t",
        "icacls ${local.secrets_folder} /inheritance:r /t"
      ])
    )
  }
}
