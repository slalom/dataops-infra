# Lambda Policy Document To Kickoff & Configure Lambda Jobs
data "aws_iam_policy_document" "lambda_assume_policy" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]
    resources = [
      aws_lambda_function.lambda_kinesis_firehose_data_transformation.arn,
      "${aws_lambda_function.lambda_kinesis_firehose_data_transformation.arn}:*",
    ]
  }
}

# Lambda Policy To Kickoff & Configure Lambda Jobs
resource "aws_iam_role_policy" "lambda_policy" {
  name   = "${var.tap_env_prefix}_lambda_function_policy"
  role   = aws_iam_role.kinesis_firehose_stream_role.name
  policy = data.aws_iam_policy_document.lambda_assume_policy.json
}

# Lambda Policy Document To Assume Base Role
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Lambda Role
resource "aws_iam_role" "lambda" {
  name               = "${var.tap_env_prefix}_lambda_function_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# Lambda Policy Document To Write Logs To Cloudwatch
data "aws_iam_policy_document" "lambda_to_cloudwatch_assume_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# Lambda Policy To Write Logs To Cloudwatch
resource "aws_iam_role_policy" "lambda_to_cloudwatch_policy" {
  name   = "${var.tap_env_prefix}_lambda_to_cloudwatch_policy"
  role   = aws_iam_role.lambda.name
  policy = data.aws_iam_policy_document.lambda_to_cloudwatch_assume_policy.json
}

# Cloudwatch Policy Document To Assume Base Role
data "aws_iam_policy_document" "cloudwatch_logs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.default.name}.amazonaws.com"]
    }
  }
}

# Cloudwatch Policy Document To Access/Write To S3
data "aws_iam_policy_document" "cloudwatch_logs_assume_policy" {
  statement {
    effect    = "Allow"
    actions   = [
      "firehose:DescribeDeliveryStream",
      "firehose:PutRecord",
      "firehose:StartDeliveryStreamEncryption",
      "firehose:PutRecordBatch",
      "firehose:StopDeliveryStreamEncryption",
      "firehose:ListTagsForDeliveryStream",
      "firehose:TagDeliveryStream",
      "firehose:UntagDeliveryStream"
    ]
    resources = [aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream.arn]
  }
}

# Cloudwatch Role
resource "aws_iam_role" "cloudwatch_logs_role" {
  name               = "${var.tap_env_prefix}_cloudwatch_logs_role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_logs_assume_role.json
}

# Cloudwatch Policy To Access/Write To S3
resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  name   = "${var.tap_env_prefix}_cloudwatch_logs_policy"
  role   = aws_iam_role.cloudwatch_logs_role.name
  policy = data.aws_iam_policy_document.cloudwatch_logs_assume_policy.json
}

# Kinesis Firehose Policy Document To Assume Base Role
data "aws_iam_policy_document" "kinesis_firehose_stream_assume_role" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRole"]
    principals {
        type        = "Service"
        identifiers = ["firehose.amazonaws.com"]
    }
  }
}

# Kinesis Firehose Role
resource "aws_iam_role" "kinesis_firehose_stream_role" {
  name               = "${var.tap_env_prefix}_fh_stream_role"
  assume_role_policy = data.aws_iam_policy_document.kinesis_firehose_stream_assume_role.json
}

# Kinesis Firehose Policy Document To Access S3
data "aws_iam_policy_document" "kinesis_firehose_access_bucket_assume_policy" {
  statement {
    effect = "Allow"
    actions = [
        "s3:AbortMultipartUpload",
        "s3:GetBucketLocation",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:PutObject"
    ]
    resources = [
      var.logging_bucket_arn,
      "${logging_bucket_arn}/*",
    ]
  }
}

# Kinesis Firehose Policy To Access S3
resource "aws_iam_role_policy" "kinesis_firehose_access_bucket_policy" {
  name   = "${var.tap_env_prefix}_fh_access_bucket_policy"
  role   = aws_iam_role.kinesis_firehose_stream_role.name
  policy = data.aws_iam_policy_document.kinesis_firehose_access_bucket_assume_policy.json
}