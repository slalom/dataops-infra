module "s3_store_and_lambdas" {
  # source      = "git::https://github.com/slalom-ggp/dataops-infra.git//catalog/aws/data-lake?ref=master"
  source      = "../../catalog/aws/data-lake"
  name_prefix = "${lower(local.name_prefix)}extracts-store-"
  environment = module.env.environment

  # ADD OR MODIFY CONFIGURATION HERE:

  //  lambda_python_source = "${path.module}/python/fn_lambda_logger"
  //  s3_triggers = {
  //    "fn_lambda_logger" = {
  //      triggering_path     = "uploads/*"
  //      function_handler    = "main.lambda_handler"
  //      environment_vars    = {}
  //      environment_secrets = {}
  //    }
  //  }
}
