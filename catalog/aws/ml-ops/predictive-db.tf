module "predictive_db" {
  count         = var.enable_predictive_db ? 1 : 0
  source        = "../../../catalog/aws/postgres"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  postgres_version = "11"
  database_name    = var.predictive_db_name

  admin_username = var.predictive_db_admin_user
  admin_password = var.predictive_db_admin_password

  storage_size_in_gb = var.predictive_db_storage_size_in_gb
  instance_class     = var.predictive_db_instance_class
}
