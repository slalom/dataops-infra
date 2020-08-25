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

data "http" "icanhazip" {
  count = var.whitelist_terraform_ip ? 1 : 0
  url   = "http://ipv4.icanhazip.com"
}

resource "random_id" "random_pass" {
  byte_length = 8
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "${lower(var.name_prefix)}rds-subnet-group"
  subnet_ids = var.environment.public_subnets
  tags       = var.resource_tags
}

data "aws_vpc" "vpc_lookup" {
  id = var.environment.vpc_id
}

resource "aws_security_group" "tf_admin_ip_whitelist" {
  count       = var.whitelist_terraform_ip ? 1 : 0
  name_prefix = "${var.name_prefix}rds-tf-admin-whitelist"
  description = "Allow JDBC traffic from Terraform Admin IP"
  vpc_id      = var.environment.vpc_id
  tags        = var.resource_tags

  ingress {
    protocol    = "tcp"
    description = "Allow RDS inbound traffic from Terraform Admin IP"
    from_port   = var.jdbc_port
    to_port     = var.jdbc_port
    cidr_blocks = ["${chomp(data.http.icanhazip[0].body)}/32"]
  }
}

resource "aws_security_group" "jdbc_cidr_whitelist" {
  count       = length(var.jdbc_cidr) > 0 ? 1 : 0
  name_prefix = "${var.name_prefix}redshift-jdbc-cidr-whitelist"
  description = "Allow query traffic from specified JDBC CIDR"
  vpc_id      = var.environment.vpc_id
  tags        = var.resource_tags

  ingress {
    protocol    = "tcp"
    description = "Allow Redshift inbound traffic from JDBC CIDR"
    from_port   = var.jdbc_port
    to_port     = var.jdbc_port
    cidr_blocks = var.jdbc_cidr
  }
}

resource "aws_security_group" "rds_security_group" {
  name_prefix = "${var.name_prefix}rds-subnet-group"
  description = "Allow JDBC traffic from VPC subnets"
  vpc_id      = var.environment.vpc_id
  tags        = var.resource_tags

  egress {
    protocol    = "tcp"
    description = "Allow all outbound traffic"
    from_port   = var.jdbc_port
    to_port     = var.jdbc_port
    # from_port   = "0"
    # to_port     = "65535"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    description = "Allow RDS inbound traffic from VPC ${var.environment.vpc_id}"
    from_port   = var.jdbc_port
    to_port     = var.jdbc_port
    cidr_blocks = [data.aws_vpc.vpc_lookup.cidr_block]
  }
}

resource "aws_db_instance" "rds_db" {
  identifier          = lower(var.identifier)
  name                = var.database_name
  engine              = var.engine
  engine_version      = var.engine_version
  predictive_db_instance_class      = var.predictive_db_instance_class
  kms_key_id          = var.kms_key_id
  port                = var.jdbc_port
  skip_final_snapshot = var.skip_final_snapshot
  allocated_storage   = var.predictive_db_storage_size_in_gb
  username            = var.admin_username
  password            = var.admin_password

  publicly_accessible = true

  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = flatten([
    [aws_security_group.rds_security_group.id],
    aws_security_group.tf_admin_ip_whitelist.*.id,
    aws_security_group.jdbc_cidr_whitelist.*.id,
  ])

  # apply_immediately   = true
}
