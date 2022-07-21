# Default AWS Region
data "aws_region" "default" {}

# Clouwatch Group For Kinesis Logging
resource "aws_cloudwatch_log_group" "kinesis_firehose_stream_logging_group" {
  name = "/aws/kinesisfirehose/${var.tap_env_prefix}"
}

# Cloudwatch Stream For Kinesis Logging
resource "aws_cloudwatch_log_stream" "kinesis_firehose_stream_logging_stream" {
  log_group_name = aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name
  name           = "S3Delivery"
}

# Kinesis Firehose Delivery Stream
resource "aws_kinesis_firehose_delivery_stream" "kinesis_firehose_stream" {
  name        = "${var.tap_env_prefix}-Tap-SingerLogs-FirehoseStream-Task"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn       = aws_iam_role.kinesis_firehose_stream_role.arn
    bucket_arn     = var.logging_bucket_arn
    prefix         = var.bucket_subdirectory
    processing_configuration {
      enabled = true

      processors {
        type = "Lambda"
        parameters {
            parameter_name  = "LambdaArn"
            parameter_value = "${aws_lambda_function.lambda_kinesis_firehose_data_transformation.arn}:$LATEST"
        }
        parameters {
            parameter_name  = "BufferSizeInMBs"
            parameter_value = 1
          }
        parameters {
            parameter_name  = "BufferIntervalInSeconds"
            parameter_value = 60
        }
      }
    }
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "${aws_cloudwatch_log_group.kinesis_firehose_stream_logging_group.name}"
      log_stream_name = "${aws_cloudwatch_log_stream.kinesis_firehose_stream_logging_stream.name}"
    }
  }
}

# File pointer
data "archive_file" "kinesis_firehose_data_transformation" {
  type        = "zip"
  source_file = "${path.module}/functions/index.js"
  output_path = "${path.module}/functions/index.zip"
}

# Lambda Function
resource "aws_lambda_function" "lambda_kinesis_firehose_data_transformation" {
  filename         = data.archive_file.kinesis_firehose_data_transformation.output_path
  function_name    = "${var.tap_env_prefix}_Index"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.kinesis_firehose_data_transformation.output_base64sha256
  runtime          = "nodejs12.x"
  timeout          = 60
}

# Subscription Filter
resource "aws_cloudwatch_log_subscription_filter" "cloudwatch_subscription_filter" {
  name            = "${var.tap_env_prefix}-Tap-SingerLogs-SubscriptionFilter-Task"
  log_group_name  = "${var.tap_env_prefix}"
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream.arn
  distribution    = "ByLogStream"
  role_arn        = aws_iam_role.cloudwatch_logs_role.arn
}