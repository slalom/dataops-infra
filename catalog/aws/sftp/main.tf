resource "aws_iam_role" "sftp_service_role" {
  name               = "${var.name_prefix}sftp-server-iam-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "transfer.amazonaws.com"
      },
    "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "transfer_service_role_policy" {
  name   = "${var.name_prefix}sftp-server-iam-policy"
  role   = aws_iam_role.sftp_service_role.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowFullAccesstoCloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_transfer_server" "sftp_server" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.sftp_service_role.arn
  tags = merge(var.resource_tags, {
    Name = "${var.name_prefix}transfer-server"
  })
}
