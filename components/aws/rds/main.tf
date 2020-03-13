/*
* Deploys an RDS-backed database. RDS currently supports the following database engines:
* * Aurora
* * MySQL
* * PostgreSQL
* * Oracle
* * SQL Server
*
* Each engine type has it's own required configuration. For already-configured database
* configurations, see the catalog modules: `catalog/aws/mysql` and `catalog/aws/postgres`
* which are built on top of this component module.
*
* * NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account
*/

resource "random_id" "random_pass" {
  byte_length = 8
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "${lower(var.name_prefix)}rds-subnet-group"
  subnet_ids = var.environment.public_subnets
  tags       = var.resource_tags
}

resource "aws_db_instance" "rds_db" {
  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  identifier           = lower(var.identifier)
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  kms_key_id           = var.kms_key_id
  port                 = var.jdbc_port
  skip_final_snapshot  = var.skip_final_snapshot
  allocated_storage    = var.storage_size_in_gb
  username             = var.admin_username
  password             = var.admin_password
}
