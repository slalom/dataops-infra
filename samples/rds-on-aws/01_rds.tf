# NOTE: Requires AWS policy 'AmazonRDSFullAccess' on the terraform account

module "rds_mysql" {
  # source            = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/rds?ref=master"
  source      = "../../catalog/aws/mysql"
  name_prefix = "${local.project_shortname}-"
  environment = module.env.environment

  # CONFIGURE HERE:

  skip_final_snapshot = true

  /*
  # OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  identifier      = "mysql-db"
  node_type       = "dc2.large"  #  "dc2.large" is smallest, costs ~$200/mo: https://aws.amazon.com/redshift/pricing/
  num_nodes       = 1

  admin_password  = "asdfAS12"
  aws_region      = local.aws_region
  */
}

output "summary" { value = module.rds_mysql.summary }
