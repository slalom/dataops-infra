/*
* This is the underlying technical component which supports the Redshift catalog module.
*
* NOTE: Requires AWS policy 'AmazonRedshiftFullAccess' on the terraform account
*/


data "http" "icanhazip" {
  count = var.whitelist_terraform_ip ? 1 : 0
  url   = "http://ipv4.icanhazip.com"
}

data "aws_vpc" "vpc_lookup" {
  id = var.environment.vpc_id
}

resource "random_id" "random_pass" {
  byte_length = 8
}

resource "aws_redshift_subnet_group" "subnet_group" {
  name       = "${lower(var.name_prefix)}redshift-subnet-group"
  subnet_ids = var.environment.public_subnets
  tags       = var.resource_tags
}

resource "aws_security_group" "tf_admin_ip_whitelist" {
  count       = var.whitelist_terraform_ip ? 1 : 0
  name_prefix = "${var.name_prefix}redshift-tf-admin-whitelist"
  description = "Allow JDBC traffic from Terraform Admin IP"
  vpc_id      = var.environment.vpc_id
  tags        = var.resource_tags

  ingress {
    protocol    = "tcp"
    description = "Allow Redshift inbound traffic from Terraform Admin IP"
    from_port   = var.jdbc_port
    to_port     = var.jdbc_port
    cidr_blocks = ["${chomp(data.http.icanhazip[0].body)}/32"]
  }
}

resource "aws_security_group" "redshift_security_group" {
  name_prefix = "${var.name_prefix}redshift-subnet-group"
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
    description = "Allow Redshift inbound traffic from VPC ${var.environment.vpc_id}"
    from_port   = var.jdbc_port
    to_port     = var.jdbc_port
    cidr_blocks = [data.aws_vpc.vpc_lookup.cidr_block]
  }
}

resource "aws_redshift_cluster" "redshift" {
  cluster_identifier        = coalesce(var.identifier, "${lower(replace(var.name_prefix, "--", "-"))}redshift")
  cluster_subnet_group_name = aws_redshift_subnet_group.subnet_group.name
  database_name             = var.database_name

  master_username = var.admin_username
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

  vpc_security_group_ids = flatten([
    [aws_security_group.redshift_security_group.id],
    aws_security_group.tf_admin_ip_whitelist.*.id
  ])

  logging {
    enable        = var.s3_logging_bucket == null ? false : true
    bucket_name   = var.s3_logging_bucket
    s3_key_prefix = var.s3_logging_path
  }

  tags = var.resource_tags
}
