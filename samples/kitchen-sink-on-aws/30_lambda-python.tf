module "triggered_lambda" {
  source        = "../../components/aws/lambda-python"
  name_prefix   = local.name_prefix
  resource_tags = local.resource_tags
  environment   = module.env.environment

  runtime              = "python3.8"
  lambda_source_folder = "${path.module}/lambda/fn_lambda_logger"
  upload_to_s3         = false
  upload_to_s3_path    = null

  functions = {
    LambdaLogger2 = {
      description = "Logs some text and exists."
      handler     = "main.lambda_handler"
      environment = {}
      secrets     = {}
    }
  }
  s3_triggers = [
    {
      function_name = "LambdaLogger2"
      s3_bucket     = module.data_lake.s3_data_bucket
      s3_path       = "*"
    }
  ]

  /*

  Optionally, you can override the pip installer used to package the lambda zip:

  pip_path = "pip3"

  */
}
