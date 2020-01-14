module "data_late_on_aws" {
  source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/data-lake-on-aws?ref=master"
  name_prefix = "${local.project_shortname}-Tableau-"
  aws_region  = local.aws_region
}
