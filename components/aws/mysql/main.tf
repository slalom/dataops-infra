# NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

resource "random_id" "random_pass" {
  byte_length = 8
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "${lower(var.name_prefix)}mysql-subnet-group"
  subnet_ids = var.environment.public_subnets
  tags       = var.resource_tags
}

resource "aws_db_instance" "mysql" {
  /*cluster_identifier        = "${lower(var.name_prefix)}redshift" */ /* MR - is this required for RDS ? */
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  identifier           = lower(var.identifier)
  engine               = var.engine
  engine_version       = var.engine_version
  # master_username      = "mysqladmin"
  # master_password = (
  #   var.admin_password == null
  #   ? "${lower(substr(random_id.random_pass.hex, 0, 4))}${upper(substr(random_id.random_pass.hex, 4, 4))}"
  #   : var.admin_password
  # )

  instance_class = var.instance_class
  # number_of_nodes = var.num_nodes
  # cluster_type    = var.num_nodes > 1 ? "multi-node" : "single-node"
  kms_key_id = var.kms_key_id
  # elastic_ip          = var.elastic_ip
  port                = var.jdbc_port
  skip_final_snapshot = var.skip_final_snapshot

  # logging {
  #   enable        = var.s3_logging_bucket == null ? false : true
  #   bucket_name   = var.s3_logging_bucket
  #   s3_key_prefix = var.s3_logging_path
  # }
}
