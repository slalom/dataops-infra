resource "aws_secretsmanager_secret" "secret_mgr_store" {
  name = var.name
}
