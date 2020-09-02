output "data_lake_summary" { value = module.data_lake_with_lambda_trigger.summary }
module "data_lake_with_lambda_trigger" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=main"
  source        = "../../catalog/aws/data-lake"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  lambda_python_source = "${path.module}/python/fn_lambda_logger"
  s3_triggers = {
    "fn_lambda_logger" = {
      triggering_path     = "uploads/*"
      lambda_handler      = "main.lambda_handler"
      environment_vars    = {}
      environment_secrets = {}
    }
  }
}
