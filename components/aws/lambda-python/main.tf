locals {
  function_names = toset([
    for trigger in var.s3_triggers :
    trigger.function_name
  ])
  s3_triggers       = zipmap(local.function_names, var.s3_triggers)
  temp_build_folder = "${path.root}/.terraform/tmp/${var.name_prefix}lambda-zip"
  zip_local_path    = "${local.temp_build_folder}/../${var.name_prefix}lambda.zip"
  is_windows        = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}

resource "aws_lambda_function" "python_lambda" {
  for_each          = local.function_names
  s3_bucket         = aws_s3_bucket_object.s3_lambda_zip.bucket
  s3_key            = aws_s3_bucket_object.s3_lambda_zip.id
  # s3_object_version = aws_s3_bucket_object.s3_lambda_zip.version_id  # requires bucket versioning enabled
  source_code_hash  = data.archive_file.lambda_zip.output_base64sha256
  function_name     = each.value
  role              = aws_iam_role.iam_for_lambda.arn
  handler           = local.s3_triggers[each.value].function_handler
  runtime           = var.runtime
  timeout           = var.timeout_seconds
  environment {
    variables = coalesce(local.s3_triggers[each.value].environment_vars, {})
  }
  # source_code_hash  = data.archive_file.lambda_zip.output_base64sha256  # triggers redundant updates if supplied
  # dynamic "environment" {
  #   for_each = local.s3_triggers[each.value].environment_vars
  #   content {
  #     variables = environment.value
  #   }
  # }
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_log_group,
    data.archive_file.lambda_zip
  ]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${var.name_prefix}lambda"
  # retention_in_days = 14
}

# resource "aws_lambda_layer_version" "python_requirements_layer" {
#   filename            = "${var.name_prefix}requirements.zip"
#   layer_name          = "${var.name_prefix}requirements"
#   compatible_runtimes = [var.runtime]
# }

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.s3_trigger_bucket

  dynamic "lambda_function" {
    for_each = local.function_names
    content {
      lambda_function_arn = aws_lambda_function.python_lambda[lambda_function.value].arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = split("*", local.s3_triggers[lambda_function.value].triggering_path)[0]
      filter_suffix       = split("*", local.s3_triggers[lambda_function.value].triggering_path)[1]
    }
  }
}
