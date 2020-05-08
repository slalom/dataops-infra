# NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

output "summary" { value = module.rds_mysql.summary }
module "rds_mysql" {
  # source    = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/mysql?ref=master"
  source        = "../../catalog/aws/mysql"
  name_prefix   = "${local.project_shortname}-"
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  identifier          = "rds-db"
  admin_username      = "mysqladmin"
  admin_password      = "asdfASDF12"
  skip_final_snapshot = true # allows simple DB deletion for POC environments

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  mysql_version       = "5.7.26"
  instance_class      = "db.t2.micro"
  jdbc_port           = 3306
  storage_size_in_gb  = 20

  */

}
