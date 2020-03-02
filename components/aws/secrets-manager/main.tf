data "local_file" "secrets_yml" {
  count    = var.secrets_file == null && length(var.secrets_file_map) == 0 ? 0 : 1
  filename = var.secrets_file
}

locals {
  file_contents = try(
    yamldecode(data.local_file.secrets_yml[0].content),
    # jsondecode(data.local_file.secrets_yml[0].content),
    {}
  )
  secrets_map = {
    for secret_name, location in var.secrets_file_map :
    secret_name => local.file_contents[location]
  }
  secrets_names = toset(keys(local.secrets_map))
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each   = local.secrets_names
  name       = "${var.name_prefix}${each.key}"
  kms_key_id = var.kms_key_id
}

resource "aws_secretsmanager_secret_version" "secrets_value" {
  for_each      = local.secrets_map
  secret_id     = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value
}
