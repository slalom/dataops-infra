# NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

output "summary" { value = module.rds_postgres.summary }
module "rds_postgres" {
  # source    = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/postgres?ref=master"
  source        = "../../catalog/aws/postgres"
  name_prefix   = "${local.project_shortname}-"
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  identifier          = "rds-postgres-db"
  admin_username      = "postgresadmin"
  admin_password      = "asdfASDF12"
  skip_final_snapshot = true

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  postgres_version    = "11.5"
  instance_class      = "db.t2.micro"
  jdbc_port           = 5432
  storage_size_in_gb  = 20

  */
}

#OPTIONAL CONFIGURATION HERE


