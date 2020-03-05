module "data_lake_with_lambda_trigger" {

  # BOILERPLATE HEADER (NO NEED TO CHANGE):
  source        = "../../catalog/aws/data-lake"
  name_prefix   = local.name_prefix
  resource_tags = local.resource_tags
  environment   = module.env.environment

  # ADD OR MODIFY CONFIGURATION HERE:

  lambda_python_source = "${path.module}/python/fn_lambda_logger"
  s3_triggers = {
    "fn_lambda_logger" = {
      triggering_path     = "uploads/*"
      function_handler    = "main.lambda_handler"
      environment_vars    = {}
      environment_secrets = {}
    }
  }

  /* OPTIONALLY, COPY-PASTE ADDITIONAL SETTINGS FROM BELOW:

  # vpc_id          = module.vpc.vpc_id
  # public_subnets  = module.vpc.public_subnets
  # private_subnets = module.vpc.private_subnets

  */

}

# BOILERPLATE OUTPUT (NO NEED TO CHANGE):
output "data_lake_summary" { value = module.data_lake_with_lambda_trigger.summary }
