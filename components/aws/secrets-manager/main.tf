data "local_file" "secrets_yml" {
  count    = var.secrets_source_file_path == null && length(var.secrets_names) == 0 ? 0 : 1
  filename = var.secrets_source_file_path
}

locals {
  secrets_map = try(yamldecode(data.local_file.secrets_yml[0].content), {})
}

resource "aws_secretsmanager_secret" "secrets" {
  for_each   = var.secrets_names
  name       = "${var.name_prefix}${each.value}"
  kms_key_id = var.kms_key_id
}

resource "aws_secretsmanager_secret_version" "secrets_value" {
  for_each      = var.secrets_names
  secret_id     = aws_secretsmanager_secret.secrets[each.value].id
  secret_string = jsonencode(local.secrets_map[each.value])
}
