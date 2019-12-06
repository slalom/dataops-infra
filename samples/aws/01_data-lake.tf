module "data_late_on_aws" {
  source      = "../../catalog/data-lake-on-aws"
  name_prefix = "${var.project_shortname}-Tableau-"
  aws_region  = var.aws_region
}
