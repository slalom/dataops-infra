module "data_lake_on_aws" {
# source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source      = "../../catalog/aws/data-lake"
  name_prefix = "${local.project_shortname}-Tableau-"
  aws_region  = local.aws_region
}
