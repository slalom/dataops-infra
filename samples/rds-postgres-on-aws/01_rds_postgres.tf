# NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

module "rds_postgres" {
  # source            = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/rds?ref=master"
  source      = "../../catalog/aws/postgres"
  name_prefix = "${local.project_shortname}-"
  environment = module.env.environment

  # CONFIGURE HERE:


  identifier          = "rds-postgres-db"
  instance_class      = "db.t2.micro"
  engine              = "postgres"
  engine_version      = "11.5"
  admin_username      = "postgresadmin"
  admin_password      = "asdfASDF12"
  jdbc_port           = 5432
  allocated_storage   = 10
  skip_final_snapshot = true

}
output "summary" { value = module.rds_postgres.summary }

