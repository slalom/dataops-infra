# NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

locals {
  name_prefix = "${var.name_prefix}MySQL-"
}

module "mysql" {
  source              = "../../../components/aws/mysql"
  name_prefix         = local.name_prefix
  environment         = var.environment
  resource_tags       = var.resource_tags
  skip_final_snapshot = var.skip_final_snapshot
  #admin_password      = var.admin_password
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  engine            = var.engine
  engine_version    = var.engine_version
  num_nodes         = var.num_nodes
  kms_key_id        = var.kms_key_id
  elastic_ip        = var.elastic_ip
  jdbc_port         = var.jdbc_port
  s3_logging_bucket = var.s3_logging_bucket
  s3_logging_path   = var.s3_logging_path
}
