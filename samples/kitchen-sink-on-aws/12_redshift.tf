locals {
  redshift_admin_user = "rsadmin"
  redshift_admin_pass = "AsdF1234"
  redshift_db_name    = "redshift_db"
}

output "redshift_summary" { value = module.redshift.summary }
module "redshift" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../catalog/aws/redshift"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  identifier          = "redshift-db"
  database_name       = local.redshift_db_name
  admin_username      = local.redshift_admin_user
  admin_password      = local.redshift_admin_pass
  skip_final_snapshot = true # allows immediate DB deletion for POC environments

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  jdbc_cidr = ["0.0.0.0/0"] # Allow query connections from any IP

  */

}
