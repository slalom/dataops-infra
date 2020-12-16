/*
* AWS Lambda is a platform which enables serverless execution of arbitrary functions. This module specifically focuses on the
* Python implementatin of Lambda functions. Given a path to a folder of one or more python fyles, this module takes care of
* packaging the python code into a zip and uploading to a new Lambda Function in AWS. The module can also be configured with
* S3-based triggers, to run the function automatically whenever a file is landed in a specific S3 path.
*
*/

resource "random_id" "suffix" {
  byte_length = 2
}

locals {
  is_disabled     = length(var.functions) == 0 ? true : false
  has_s3_triggers = var.s3_triggers == null ? false : length(var.s3_triggers) > 0 ? true : false
  is_windows      = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  pip_path        = coalesce(var.pip_path, local.is_windows ? "pip" : "pip3")
  random_suffix   = lower(random_id.suffix.dec)
  function_names  = toset(keys(var.functions))
  function_secrets = {
    for name in local.function_names :
    name => var.functions[name].secrets
    if length(var.functions[name].secrets) > 0
  }
  source_files_hash = local.is_disabled ? "null" : join(",", [
    for filepath in fileset(var.lambda_source_folder, "*") :
    filebase64sha256("${var.lambda_source_folder}/${filepath}")
  ])
  unique_hash                 = local.is_disabled ? "na" : md5(local.source_files_hash)
  temp_artifacts_root         = "${path.root}/.terraform/tmp"
  temp_build_folder           = "${local.temp_artifacts_root}/${var.name_prefix}lambda-zip-${local.unique_hash}"
  local_requirements_file     = fileexists("${var.lambda_source_folder}/requirements.txt") ? "${var.lambda_source_folder}/requirements.txt" : null
  local_dependencies_zip_path = "${local.temp_artifacts_root}/${var.name_prefix}lambda-dependencies-${local.unique_hash}.zip"
  # local_source_zip_path       = "${local.temp_artifacts_root}/${var.name_prefix}lambda-source-${local.unique_hash}.zip"
  triggering_bucket_names = var.s3_triggers == null ? [] : [
    for bucket in distinct([
      for trigger in var.s3_triggers :
      trigger.s3_bucket
    ]) :
    bucket
  ]
  # TODO - add override for 'layered' or 'standalone' functions which don't need dependencies
  upload_to_s3 = local.local_requirements_file == null ? false : true
}

resource "aws_lambda_function" "python_lambda" {
  for_each = local.function_names

  # filename = local.local_source_zip_path
  filename = local.local_dependencies_zip_path
  # layers   = local.local_requirements_file == null ? null : [aws_lambda_layer_version.requirements_layer[0].arn]

  # if var.upload_to_s3 == true: use S3 path; otherwise upload directly from local zip path
  # s3_bucket = aws_s3_bucket_object.dependencies_layer_s3_zip[0].bucket
  # s3_key    = aws_s3_bucket_object.dependencies_layer_s3_zip[0].id
  # s3_bucket = local.upload_to_s3 == false ? null : aws_s3_bucket_object.dependencies_layer_s3_zip[0].bucket
  # s3_key    = local.upload_to_s3 == false ? null : aws_s3_bucket_object.dependencies_layer_s3_zip[0].id
  # source_code_hash = local.unique_hash # filebase64sha256(local.local_dependencies_zip_path)

  function_name = "${var.name_prefix}${each.value}-${substr(local.unique_hash, 0, 4)}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.functions[each.value].handler
  runtime       = var.runtime
  timeout       = var.timeout_seconds
  environment {
    variables = merge(
      var.functions[each.value].environment,
      var.functions[each.value].secrets,
      var.resource_tags
    )
  }
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_log_group,
    null_resource.create_dependency_zip,
    # null_resource.pip,
    # data.archive_file.lambda_zip,
  ]
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  count = local.is_disabled ? 0 : 1
  name  = "/aws/lambda/${var.name_prefix}lambda-${local.random_suffix}"
  # retention_in_days = 14
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  count  = var.s3_triggers == null ? 0 : length(var.s3_triggers)
  bucket = var.s3_triggers[count.index].s3_bucket
  lambda_function {
    lambda_function_arn = aws_lambda_function.python_lambda[var.s3_triggers[count.index].function_name].arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = split("*", var.s3_triggers[count.index].s3_path)[0]
    filter_suffix       = split("*", var.s3_triggers[count.index].s3_path)[1]
  }
}
