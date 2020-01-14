module "redshift_dw" {
  # source          = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/redshift-on-aws?ref=master"
  source            = "../../catalog/redshift-on-aws"
  project_shortname = local.project_shortname
  # node_type         = "dc2.large"
  # admin_password    = "asdfAS12"
  # aws_region        = local.aws_region
}
