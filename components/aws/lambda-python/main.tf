resource "random_id" "suffix" {
  byte_length = 2
}

locals {
  random_suffix  = lower(random_id.suffix.hex)
  is_disabled    = length(var.s3_triggers) == 0
  function_names = toset(keys(var.s3_triggers))
  functions_with_secrets = toset([
    for name in local.function_names :
    name
    if length(var.s3_triggers[name].environment_secrets) > 0
  ])
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  source_files_hash = local.is_disabled ? "null" : join(",", [
    for filepath in fileset(var.lambda_source_folder, "*") :
    filebase64sha256("${var.lambda_source_folder}/${filepath}")
  ])
  unique_hash       = local.is_disabled ? "na" : md5(local.source_files_hash)
  temp_build_folder = "${path.root}/.terraform/tmp/${var.name_prefix}lambda-zip-${local.unique_hash}"
  zip_local_path    = "${local.temp_build_folder}/../${var.name_prefix}lambda-${local.unique_hash}.zip"
}

resource "aws_lambda_function" "python_lambda" {
  for_each  = local.function_names
  s3_bucket = aws_s3_bucket_object.s3_lambda_zip[0].bucket
  s3_key    = aws_s3_bucket_object.s3_lambda_zip[0].id
  # s3_object_version = aws_s3_bucket_object.s3_lambda_zip[0].version_id  # requires bucket versioning enabled
  source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256
  function_name    = each.value
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = var.s3_triggers[each.value].function_handler
  runtime          = var.runtime
  timeout          = var.timeout_seconds
  environment {
    variables = merge(
      var.s3_triggers[each.value].environment_vars,
      var.s3_triggers[each.value].environment_secrets,
      var.resource_tags
    )
  }
  # source_code_hash  = data.archive_file.lambda_zip[0].output_base64sha256  # triggers redundant updates if supplied
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_log_group,
    data.archive_file.lambda_zip
  ]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  count = local.is_disabled ? 0 : 1
  name  = "/aws/lambda/${var.name_prefix}lambda-${local.random_suffix}"
  # retention_in_days = 14
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = local.is_disabled ? 0 : 1
  bucket = var.s3_trigger_bucket
  dynamic "lambda_function" {
    for_each = local.function_names
    content {
      lambda_function_arn = aws_lambda_function.python_lambda[lambda_function.value].arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = split("*", var.s3_triggers[lambda_function.value].triggering_path)[0]
      filter_suffix       = split("*", var.s3_triggers[lambda_function.value].triggering_path)[1]
    }
  }
}
