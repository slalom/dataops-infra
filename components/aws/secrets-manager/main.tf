/*
* This module takes as input a set of maps from variable names to secrets locations (in YAML or
* JSON). The module uploads those secrets to AWS Secrets Manager and returns the same map pointing
* to the IDs of new AWS Secrets manager locations. Those IDs (aka ARNs) can then safely be handed
* on to other resources which required access to those secrets.
*
* **Usage Notes:**
*
* * Any secrets locations which are already pointing to AWS secrets will simply be passed back through to the output with no changes.
* * For security reasons, this module does not accept inputs for secrets using the clear text of the secrets themselves. To properly use this module, first save the secrets to a YAML or JSON file which is excluded from source control.
*
*/

resource "random_id" "suffix" { byte_length = 2 }

locals {
  secrets_names = toset(keys(var.secrets_map))
  existing_secrets_ids_map = {
    # filter existing map for secrets already stored in AWS secrets manager
    for secret_name, location in var.secrets_map :
    secret_name => location
    if replace(secret_name, ":secretsmanager:", "") != secret_name
  }
  new_yaml_secrets_map = {
    # raw secrets which have not yet been stored in AWS secrets manager
    for secret_name, location in var.secrets_map :
    # split the filename from the key name using the ':' delimeter and return the
    # secret value the file. If there's no ":" after the file name, the secret_name will
    # be used also as the key within the file.
    secret_name => yamldecode(
      file(split(":", location)[0])
    )[flatten([split(":", location), [secret_name]])[1]] # On failure, please check that the file contains the keys specified.
    if replace(replace(replace(lower(
      location
    ), ".json", ""), ".yml", ""), ".yaml", "") != lower(location)
  }
  new_aws_creds_secrets_map = {
    # raw secrets which have not yet been stored in AWS secrets manager
    for secret_name, location in var.secrets_map :
    # split the filename from the key name using the ':' delimeter and return the
    # secret value the file
    secret_name => regex("${split(":", location)[1]}\\s*?=\\s?(.*)\\b", file(split(":", location)[0]))[0]
    # if the secret is an AWS credential:
    if replace(replace(lower(
      location
    ), ":aws_access_key_id", ""), ":aws_secret_access_key", "") != lower(location)
    # And if NOT in a json/yml file:
    and replace(replace(replace(lower(
      location
    ), ".json", ""), ".yml", ""), ".yaml", "") == lower(location)
  }
  new_secrets_map = merge(local.new_yaml_secrets_map, local.new_aws_creds_secrets_map)
  merged_secrets_map = merge(
    local.existing_secrets_ids_map, {
      for created_name in keys(local.new_secrets_map) :
      created_name => aws_secretsmanager_secret.secrets[created_name].id
    }
  )
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each   = toset(keys(local.new_secrets_map))
  name       = "${var.name_prefix}${each.key}-${random_id.suffix.dec}"
  kms_key_id = var.kms_key_id
}

resource "aws_secretsmanager_secret_version" "secrets_value" {
  for_each      = local.new_secrets_map
  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value
}
