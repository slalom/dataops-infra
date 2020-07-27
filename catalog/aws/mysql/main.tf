/*
* Deploys a MySQL server running on RDS.
*
* * NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account
*/

locals {
  name_prefix = "${var.name_prefix}MySQL-"
}

module "mysql" {
  source        = "../../../components/aws/rds"
  name_prefix   = local.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags
  identifier    = var.identifier

  skip_final_snapshot = var.skip_final_snapshot
  database_name       = var.database_name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  instance_class      = var.instance_class
  engine              = "mysql"
  engine_version      = var.mysql_version
  kms_key_id          = var.kms_key_id
  jdbc_port           = var.jdbc_port
  storage_size_in_gb  = var.storage_size_in_gb

  jdbc_cidr              = var.jdbc_cidr
  whitelist_terraform_ip = var.whitelist_terraform_ip
}
