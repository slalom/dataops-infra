# NOTE: Requires AWS policy 'AmazonRedshiftFullAccess' on the terraform account

module "redshift_dw" {
  # source            = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/redshift?ref=master"
  source        = "../../catalog/aws/redshift"
  name_prefix   = "${local.project_shortname}-"
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:

  skip_final_snapshot = true

  /*
  # OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  node_type         = "dc2.large"  #  "dc2.large" is smallest, costs ~$200/mo: https://aws.amazon.com/redshift/pricing/
  num_nodes         = 1

  admin_password    = "asdfAS12"
  aws_region        = local.aws_region
  */
}

output "summary" { value = module.redshift_dw.summary }
