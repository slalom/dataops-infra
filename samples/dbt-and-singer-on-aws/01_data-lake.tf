module "data_lake_on_aws" {
  # source        = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source        = "../../catalog/aws/data-lake"
  name_prefix   = local.name_prefix
  resource_tags = local.resource_tags

  # ADD OR MODIFY CONFIGURATION HERE:



  /*
  # OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  admin_cidr            = []
  default_cidr          = ["0.0.0.0/0"]
  */
}
