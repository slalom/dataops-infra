module "airflow" {
  # source          = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/airflow-on-aws?ref=master"
  source            = "../../catalog/airflow-on-aws"
  project_shortname = local.project_shortname

  # CONFIGURE HERE:


  /*
  # OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  node_type         = "t2.small"  # https://aws.amazon.com/ec2/pricing/

  admin_password    = "asdfAS12"
  aws_region        = local.aws_region
  */
}

output "summary" { value = module.redshift_dw.summary }
