# NOTE: This module requires the python `pip` tool in order
# to package and deploy the lambda function code. If you have
# difficulty deploying this module, you can try modifying the
# optional 'pip_path' variable, or simply change the file
# extention to to '.tf.disabled' in order to disable just this
# module.

module "triggered_lambda" {
  source        = "../../components/aws/lambda-python"
  name_prefix   = local.name_prefix
  resource_tags = local.resource_tags
  environment   = module.env.environment

  runtime              = "python3.8"
  lambda_source_folder = "${path.module}/lambda/fn_lambda_logger"
  s3_upload_path       = "s3://${module.data_lake.metadata_bucket}/lambda/"

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
