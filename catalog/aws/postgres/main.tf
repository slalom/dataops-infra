/*
* Deploys a Postgres server running on RDS.
*
* * NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account
*/

locals {
  name_prefix = "${var.name_prefix}PostgreSQL-"
}

module "postgres" {
  source        = "../../../components/aws/rds"
  name_prefix   = local.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags
  identifier    = var.identifier

  skip_final_snapshot = var.skip_final_snapshot
  database_name       = var.database_name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  predictive_db_instance_class      = var.predictive_db_instance_class
  engine              = "postgres"
  engine_version      = var.postgres_version
  kms_key_id          = var.kms_key_id
  jdbc_port           = var.jdbc_port
  predictive_db_storage_size_in_gb  = var.predictive_db_storage_size_in_gb

  jdbc_cidr              = var.jdbc_cidr
  whitelist_terraform_ip = var.whitelist_terraform_ip
}
