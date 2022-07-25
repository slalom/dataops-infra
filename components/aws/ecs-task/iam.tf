############################
### IAM Global Constants ###
############################

data "aws_iam_policy" "AmazonS3FullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
data "aws_iam_policy" "CloudWatchLogsFullAccess" {
  arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
data "aws_iam_policy" "SecretsManagerReadWrite" {
  arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}
data "aws_iam_policy" "AmazonSSMReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

##########################
### ECS Execution Role ###
##########################

resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.name_prefix}ECSExecutionRole-${random_id.suffix.dec}"
  tags               = var.resource_tags
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      },
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ecs_role_policy-ecr" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn
}
resource "aws_iam_role_policy_attachment" "ecs_role_policy-cwlogs" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = data.aws_iam_policy.CloudWatchLogsFullAccess.arn
}
resource "aws_iam_role_policy_attachment" "ecs_role_policy-secrets" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = data.aws_iam_policy.SecretsManagerReadWrite.arn
}
resource "aws_iam_role_policy_attachment" "ecs_role_policy-parameters" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = data.aws_iam_policy.AmazonSSMReadOnlyAccess.arn
}
resource "aws_iam_role_policy_attachment" "ecs_role_policy-kms" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.allow_kms_decrypt.arn
}
resource "aws_iam_role_policy_attachment" "ecs_role_policy-handoff" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_policy_handoff.id
}

resource "aws_iam_policy" "ecs_policy_handoff" {
  name   = "${var.name_prefix}ecs_task-policy_handoff-${random_id.suffix.dec}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask"
      ],
      "Resource": [
        "arn:aws:ecs:*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": [
        "*"
      ],
      "Condition": {
        "StringLike": {
          "iam:PassedToService": "ecs-tasks.amazonaws.com"
        }
      }
    }
  ]
}
EOF
}

#####################
### ECS Task Role ###
#####################

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.name_prefix}ECSTaskRole-${random_id.suffix.dec}"
  tags               = var.resource_tags
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "custom_ecs_task_policy" {
  name        = "${var.name_prefix}custom_ecs_tasks"
  path        = "/"
  description = "IAM policy for accessing S3 from a lambda"
  policy      = data.aws_iam_policy_document.custom_ecs_task_policy.json
}

data "aws_iam_policy_document" "custom_ecs_task_policy" {
  statement {
    actions   = ["s3:ListAllMyBuckets", "s3:GetBucketLocation"]
    resources = ["arn:aws:s3:::*"]
  }
  dynamic "statement" {
    # Must be dynamic, to prevent failure when case number of grants is zero.
    for_each = length(coalesce(var.permitted_s3_buckets, [])) > 0 ? ["1"] : []
    content {
      actions = ["s3:ListBucket"]
      resources = [
        for b in var.permitted_s3_buckets :
        "arn:aws:s3:::${b}"
      ]
    }
  }
  dynamic "statement" {
    # Must be dynamic, to prevent failure when case number of grants is zero.
    for_each = length(coalesce(var.permitted_s3_buckets, [])) > 0 ? ["1"] : []
    content {
      actions = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
      ]
      resources = [
        for b in var.permitted_s3_buckets :
        "arn:aws:s3:::${b}/*"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "custom_ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.custom_ecs_task_policy.arn
}

resource "aws_iam_policy" "allow_kms_decrypt" {
  name   = "${var.name_prefix}ecs_task-kms_decryption"
  policy = <<EOF
{
  "Id": "AllowsKmsKeyAccess",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowUseOfKey",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "listKeys",
      "Effect": "Allow",
      "Action": [
        "kms:ListKeys",
        "kms:ListAliases"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Lambda Policy Document To Kickoff & Configure Lambda Jobs
data "aws_iam_policy_document" "lambda_assume_policy" {
  count  = var.singer_metrics_flag ? 1 : 0 
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunctionConfiguration",
    ]
    resources = [
      aws_lambda_function.lambda_kinesis_firehose_data_transformation[0].arn,
      "${aws_lambda_function.lambda_kinesis_firehose_data_transformation[0].arn}:*",
    ]
  }
}

# Lambda Policy To Kickoff & Configure Lambda Jobs
resource "aws_iam_role_policy" "lambda_policy" {
  count  = var.singer_metrics_flag ? 1 : 0 
  name   = "${var.name_prefix}_lambda_function_policy"
  role   = aws_iam_role.kinesis_firehose_stream_role.name
  policy = data.aws_iam_policy_document.lambda_assume_policy[0].json
}

# Lambda Policy Document To Assume Base Role
data "aws_iam_policy_document" "lambda_assume_role" {
  count  = var.singer_metrics_flag ? 1 : 0 
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
  count              = var.singer_metrics_flag ? 1 : 0 
  name               = "${var.name_prefix}_lambda_function_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role[0].json
}

# Lambda Policy Document To Write Logs To Cloudwatch
data "aws_iam_policy_document" "lambda_to_cloudwatch_assume_policy" {
  count  = var.singer_metrics_flag ? 1 : 0 
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
  count  = var.singer_metrics_flag ? 1 : 0 
  name   = "${var.name_prefix}_lambda_to_cloudwatch_policy"
  role   = aws_iam_role.lambda[0].name
  policy = data.aws_iam_policy_document.lambda_to_cloudwatch_assume_policy[0].json
}

# Cloudwatch Policy Document To Assume Base Role
data "aws_iam_policy_document" "cloudwatch_logs_assume_role" {
  count  = var.singer_metrics_flag ? 1 : 0 
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
  count  = var.singer_metrics_flag ? 1 : 0 
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
    resources = [aws_kinesis_firehose_delivery_stream.kinesis_firehose_stream[0].arn]
  }
}

# Cloudwatch Role
resource "aws_iam_role" "cloudwatch_logs_role" {
  count              = var.singer_metrics_flag ? 1 : 0 
  name               = "${var.name_prefix}_cloudwatch_logs_role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_logs_assume_role[0].json
}

# Cloudwatch Policy To Access/Write To S3
resource "aws_iam_role_policy" "cloudwatch_logs_policy" {
  count  = var.singer_metrics_flag ? 1 : 0 
  name   = "${var.name_prefix}_cloudwatch_logs_policy"
  role   = aws_iam_role.cloudwatch_logs_role.name
  policy = data.aws_iam_policy_document.cloudwatch_logs_assume_policy[0].json
}

# Kinesis Firehose Policy Document To Assume Base Role
data "aws_iam_policy_document" "kinesis_firehose_stream_assume_role" {
  count  = var.singer_metrics_flag ? 1 : 0 
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
  count              = var.singer_metrics_flag ? 1 : 0 
  name               = "${var.name_prefix}_fh_stream_role"
  assume_role_policy = data.aws_iam_policy_document.kinesis_firehose_stream_assume_role[0].json
}

# Kinesis Firehose Policy Document To Access S3
data "aws_iam_policy_document" "kinesis_firehose_access_bucket_assume_policy" {
  count  = var.singer_metrics_flag ? 1 : 0 
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
      "${var.logging_bucket_arn}/*",
    ]
  }
}

# Kinesis Firehose Policy To Access S3
resource "aws_iam_role_policy" "kinesis_firehose_access_bucket_policy" {
  count  = var.singer_metrics_flag ? 1 : 0 
  name   = "${var.name_prefix}_fh_access_bucket_policy"
  role   = aws_iam_role.kinesis_firehose_stream_role.name
  policy = data.aws_iam_policy_document.kinesis_firehose_access_bucket_assume_policy[0].json
}
