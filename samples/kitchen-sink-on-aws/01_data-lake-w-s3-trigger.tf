output "data_lake_summary" { value = module.data_lake.summary }
module "data_lake" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=main"
  source        = "../../catalog/aws/data-lake"
  name_prefix   = local.name_prefix
  environment   = module.env.environment
  resource_tags = local.resource_tags

  lambda_python_source = "${path.module}/lambda/fn_lambda_logger"
  s3_triggers = {
    "LambdaLogger1" = {
      triggering_path     = "*"
      lambda_handler      = "main.lambda_handler"
      environment_vars    = {}
      environment_secrets = {}
    }
  }

  /*

  Optionally, you can override the pip installer used to package the lambda zip:

  pip_path = "pip3"

  */
}
