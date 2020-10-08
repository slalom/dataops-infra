/*
* Redshift is an AWS database platform which applies MPP (Massively-Parallel-Processing) principles to big data workloads in the cloud.
*
*/

# NOTE: Requires AWS policy 'AmazonRedshiftFullAccess' on the terraform account

locals {
  name_prefix = "${var.name_prefix}-RS"
}

module "redshift" {
  source              = "../../../components/aws/redshift"
  name_prefix         = local.name_prefix
  environment         = var.environment
  resource_tags       = var.resource_tags
  skip_final_snapshot = var.skip_final_snapshot
  database_name       = var.database_name
  admin_password      = var.admin_password
  admin_username      = var.admin_username
  node_type           = var.node_type
  num_nodes           = var.num_nodes
  kms_key_id          = var.kms_key_id
  elastic_ip          = var.elastic_ip
  jdbc_port           = var.jdbc_port
  s3_logging_bucket   = var.s3_logging_bucket
  s3_logging_path     = var.s3_logging_path

  jdbc_cidr              = var.jdbc_cidr
  whitelist_terraform_ip = var.whitelist_terraform_ip
}
