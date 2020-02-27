# NOTE: Requires AWS policy 'AmazonRedshiftFullAccess' on the terraform account

resource "random_id" "random_pass" {
  byte_length = 8
}

resource "aws_redshift_subnet_group" "subnet_group" {
  name       = "${lower(var.name_prefix)}redshift-subnet-group"
  subnet_ids = var.subnets
  tags       = var.resource_tags
}

resource "aws_redshift_cluster" "redshift" {
  cluster_identifier        = "${lower(var.name_prefix)}redshift"
  cluster_subnet_group_name = aws_redshift_subnet_group.subnet_group.name
  database_name             = var.database_name

  master_username = "rsadmin"
  master_password = (
    var.admin_password == null
    ? "${lower(substr(random_id.random_pass.hex, 0, 4))}${upper(substr(random_id.random_pass.hex, 4, 4))}"
    : var.admin_password
  )

  node_type           = var.node_type
  number_of_nodes     = var.num_nodes
  cluster_type        = var.num_nodes > 1 ? "multi-node" : "single-node"
  kms_key_id          = var.kms_key_id
  elastic_ip          = var.elastic_ip
  port                = var.jdbc_port
  skip_final_snapshot = var.skip_final_snapshot

  logging {
    enable        = var.s3_logging_bucket == null ? false : true
    bucket_name   = var.s3_logging_bucket
    s3_key_prefix = var.s3_logging_path
  }
}
