module "matillion" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/airflow?ref=master"
  source        = "../../catalog/aws/matillion"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  # CONFIGURE HERE:



  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  admin_password    = "asdfAS12"
  ec2_instance_type = "p3.8xlarge"
  ec2_instance_type = "m4.4xlarge"
  admin_cidr        = []
  app_cidr          = ["0.0.0.0/0"]

  */
}

output "airflow_summary" { value = module.airflow.summary }
# output "airflow_summary" { value = "module.airflow.summary" }
