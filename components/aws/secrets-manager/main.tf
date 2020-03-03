locals {
  secrets_names = toset(keys(var.secrets_map))
  existing_secrets_ids_map = {
    # filter existing map for secrets already stored in AWS secrets manager
    for secret_name, location in var.secrets_map :
    secret_name => location
    if replace(secret_name, ":secretsmanager:", "") != secret_name
  }
  new_secrets_map = {
    # raw secrets which have not yet been stored in AWS secrets manager
    for secret_name, location in var.secrets_map :
    # split the filename from the key name using the ':' delimeter and return the
    # secret value the file
    secret_name => yamldecode(
      file(split(":", location)[0])
    )[split(":", location)[1]]
    if replace(secret_name, ":secretsmanager:", "") == secret_name
  }
  merged_secrets_map = merge(
      local.existing_secrets_ids_map, {
        for created_name in keys(local.new_secrets_map):
          created_name => aws_secretsmanager_secret.secrets[created_name].id
      }
    )
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each   = keys(local.new_secrets_map)
  name       = "${var.name_prefix}${each.key}"
  kms_key_id = var.kms_key_id
}

resource "aws_secretsmanager_secret_version" "secrets_value" {
  for_each      = local.new_secrets_map
  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value
}
