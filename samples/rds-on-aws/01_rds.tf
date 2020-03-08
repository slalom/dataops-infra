# NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

module "rds_mysql" {
  # source            = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/rds?ref=master"
  source      = "../../catalog/aws/mysql"
  name_prefix = "${local.project_shortname}-"
  environment = module.env.environment

  # CONFIGURE HERE:


  identifier          = "rds-db"
  instance_class      = "db.t2.micro"
  mysql_version       = "5.7.26"
  admin_username      = "mysqladmin"
  admin_password      = "asdfASDF12"
  jdbc_port           = 3306
  allocated_storage   = 20
  skip_final_snapshot = true

}

#OPTIONAL CONFIGURATION HERE 

output "summary" { value = module.rds_mysql.summary }

