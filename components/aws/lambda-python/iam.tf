resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.name_prefix}lambda_iam_role-${local.random_suffix}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_s3_bucket" "bucket_lookup" {
  bucket = var.s3_trigger_bucket
}

resource "aws_lambda_permission" "allow_bucket" {
  for_each      = aws_lambda_function.python_lambda
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = each.value.arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.bucket_lookup.arn
}

resource "aws_iam_policy" "lambda_s3_access" {
  count = length(compact([
    for x in var.s3_triggers :
    x.triggering_path == null ? 0 : 1
  ])) > 0 ? 1 : 0
  name        = "${var.name_prefix}lambda_s3_access-${local.random_suffix}"
  path        = "/"
  description = "IAM policy for accessing S3 from a lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${var.s3_trigger_bucket}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${var.s3_trigger_bucket}/*"]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  count = length(compact([
    for x in var.s3_triggers :
    x.triggering_path == null ? 0 : 1
  ])) > 0 ? 1 : 0
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_s3_access[0].arn
}

resource "aws_iam_policy" "lambda_secrets_access" {
  for_each    = local.functions_with_secrets
  name        = "${var.name_prefix}lambda_secrets_access-${each.value}"
  path        = "/"
  description = "IAM policy for accessing secrets from a lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": [
        "${join("\", \"", values(var.s3_triggers[each.value].environment_secrets))}"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "lambda_secrets_rules" {
  for_each   = local.functions_with_secrets
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_secrets_access[each.value].arn
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${var.name_prefix}lambda_logging_policy-${local.random_suffix}"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
