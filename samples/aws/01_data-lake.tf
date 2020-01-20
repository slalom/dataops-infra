module "data_lake_on_aws" {
  source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/data-lake-on-aws?ref=master"
  # source    = "../../catalog/data-lake-on-aws"
  name_prefix           = local.name_prefix
  aws_region            = local.aws_region

  # ADD OR MODIFY CONFIGURATION HERE:



  /*
  # OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  admin_cidr            = []
  default_cidr          = ["0.0.0.0/0"]
  */
}
