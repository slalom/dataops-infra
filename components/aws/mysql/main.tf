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

  db_subnet_group_name = aws_db_subnet_group.subnet_group.name
  identifier           = lower(var.identifier)
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  kms_key_id           = var.kms_key_id
  # elastic_ip          = var.elastic_ip
  port                = var.jdbc_port
  skip_final_snapshot = var.skip_final_snapshot
  allocated_storage   = var.allocated_storage
  username            = var.admin_username
  password            = var.admin_password

  # logging {
  #   enable        = var.s3_logging_bucket == null ? false : true
  #   bucket_name   = var.s3_logging_bucket
  #   s3_key_prefix = var.s3_logging_path
  # }
}


