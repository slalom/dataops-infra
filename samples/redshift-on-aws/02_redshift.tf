# NOTE: Requires AWS policy 'AmazonRedshiftFullAccess' on the terraform account

output "summary" { value = module.redshift_dw.summary }
module "redshift_dw" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/redshift?ref=main"
  source        = "../../catalog/aws/redshift"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  skip_final_snapshot = true # allows immediate DB deletion for POC environments

  /*
  # OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  node_type         = "dc2.large"  #  "dc2.large" is smallest, costs ~$200/mo: https://aws.amazon.com/redshift/pricing/
  num_nodes         = 1

  admin_password    = "Asdf1234"
  */
}
