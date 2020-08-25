# NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

locals {
  redshift_admin_user = "rsadmin"
  redshift_admin_pass = "asdfAS12"
}

output "summary" { value = module.redshift.summary }
module "redshift" {
  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../catalog/aws/redshift"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  identifier          = "redshift-db"
  jdbc_port           = 5439
  jdbc_cidr           = ["0.0.0.0/0"] # Allow query connections from any IP
  admin_username      = local.redshift_admin_user
  admin_password      = local.redshift_admin_pass
  skip_final_snapshot = true # allows simple DB deletion for POC environments

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  mysql_version       = "5.7.26"
  predictive_db_instance_class      = "db.t2.micro"
  predictive_db_storage_size_in_gb  = 20

  */

}
