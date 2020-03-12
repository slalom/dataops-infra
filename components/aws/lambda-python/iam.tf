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
  for_each = toset(keys(local.bucket_triggers))
  bucket   = each.value
}

resource "aws_lambda_permission" "allow_bucket" {
  for_each = {
    for trigger in var.s3_triggers :
    trigger.function_name => trigger.s3_bucket
  }
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  principal     = "s3.amazonaws.com"
  function_name = aws_lambda_function.python_lambda[each.key].arn
  source_arn    = data.aws_s3_bucket.bucket_lookup[each.value].arn
}

resource "aws_iam_policy" "lambda_s3_access" {
  for_each    = toset(keys(local.bucket_triggers))
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
      "Resource": ["${data.aws_s3_bucket.bucket_lookup[each.value].arn}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["${data.aws_s3_bucket.bucket_lookup[each.value].arn}/*"]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  for_each   = toset(keys(local.bucket_triggers))
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_s3_access[each.value].arn
}

resource "aws_iam_policy" "lambda_secrets_access" {
  for_each    = local.function_secrets
  name        = "${var.name_prefix}lambda_secrets_access-${each.key}"
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
        "${join("\", \"", values(each.value))}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_secrets_rules" {
  for_each   = local.function_secrets
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_secrets_access[each.key].arn
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
