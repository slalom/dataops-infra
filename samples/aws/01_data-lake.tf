module "data_late_on_aws" {
  source      = "../../catalog/data-lake-on-aws"
  name_prefix = "${local.project_shortname}-Tableau-"
  aws_region  = local.aws_region
}
