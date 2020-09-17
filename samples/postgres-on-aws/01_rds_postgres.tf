# NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

output "summary" { value = module.rds_postgres.summary }
module "rds_postgres" {
  source = "../../catalog/aws/postgres"
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/postgres?ref=main"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  identifier          = "postgres-db"
  admin_username      = "postgresadmin"
  admin_password      = "asdf1234"
  skip_final_snapshot = true # allows immediate DB deletion for POC environments

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  postgres_version    = "11.5"
  instance_class      = "db.t2.micro"
  jdbc_port           = 5432
  storage_size_in_gb  = 20

  */
}

#OPTIONAL CONFIGURATION HERE


