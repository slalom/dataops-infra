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

resource "aws_iam_role_policy_attachment" "ecs_role_policy-S3" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}


resource "aws_iam_policy" "permitted_s3_buckets_policy" {
  count       = var.permitted_s3_buckets == null ? 0 : length(var.permitted_s3_buckets) > 0 ? 1 : 0
  name        = "${var.name_prefix}ecs_task-permitted_s3_bucket_access"
  path        = "/"
  description = "IAM policy for accessing S3 from a lambda"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${join("\", \"arn:aws:s3:::", var.permitted_s3_buckets)}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${join("/*\", \"arn:aws:s3:::", var.permitted_s3_buckets)}/*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "permitted_s3_buckets_policy_attachment" {
  count      = var.permitted_s3_buckets == null ? 0 : length(var.permitted_s3_buckets) > 0 ? 1 : 0
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.permitted_s3_buckets_policy[0].arn
}

resource "aws_iam_policy" "allow_kms_decrypt" {
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
      "Resource": "arn:aws:kms:*::alias/*"
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
