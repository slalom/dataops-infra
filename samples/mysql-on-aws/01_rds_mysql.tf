# NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

output "summary" { value = module.rds_mysql.summary }
module "rds_mysql" {
  # source    = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/mysql?ref=main"
  source        = "../../catalog/aws/mysql"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  identifier          = "rds-db"
  admin_username      = "mysqladmin"
  admin_password      = "asdf1234"
  skip_final_snapshot = true # allows immediate DB deletion for POC environments

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  mysql_version       = "5.7.26"
  predictive_db_instance_class      = "db.t2.micro"
  jdbc_port           = 3306
  predictive_db_storage_size_in_gb  = 20

  */

}
