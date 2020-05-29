resource "aws_iam_role" "sftp_iam_user_roles" {
  for_each           = var.users
  name               = each.value
  path               = "/${var.name_prefix}groups/"
  assume_role_policy = <<POLICY
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
POLICY
}

resource "aws_iam_role_policy_attachment" "role-policy-attachment" {
  for_each = toset(flatten([
    for user, groups in var.user_groups :
    [
      for group in groups :
      "${user}:${group}"
    ]
  ]))
  role       = aws_iam_role.sftp_iam_user_roles[split(":", each.value)[0]].name
  policy_arn = aws_iam_policy.group_s3_permission[split(":", each.value)[1]].arn
}

resource "aws_iam_policy" "group_s3_permission" {
  for_each = var.group_permissions
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${var.name_prefix}${each.key}-s3-policy",
  "Statement": [
    {
      "Sid": "AllowUserToSeeBucketListInTheConsole",
      "Action": ["s3:ListAllMyBuckets", "s3:GetBucketLocation"],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::*"]
    },
    {
      "Sid": "AllowRootAndHomeListingOfCompanyBucket",
      "Action": ["s3:ListBucket"],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::${var.data_bucket}"],
      "Condition":{"StringEquals":{"s3:prefix":["","home/","data/"],"s3:delimiter":["/"]}}
    },
    {
      "Sid": "AllowListingOfUserFolder",
      "Action": ["s3:ListBucket"],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::${var.data_bucket}"],
      "Condition":{"StringLike":{"s3:prefix":["home/${each.key}","home/${each.key}/*"]}}
    },
    {
      "Sid": "AllowAllS3ActionsInUserFolder",
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["arn:aws:s3:::${var.data_bucket}/home/${each.key}/*"]
    },
    ${join(
  ",\n", [
    for grant in each.value :
    <<EOF2
    {
      "Sid": "AllowS3${grant.write ? "Writes" : "Reads"}FOR${replace(replace(each.key, "-", ""), "_", "")}ON${replace(replace(replace(grant.path, "/", ""), "-", ""), "_", "")}",
      "Effect": "Allow",
      "Action": [${grant.write ? "\"s3:*\"" : "\"s3:GetObject\""}],
      "Resource": [
        "arn:aws:s3:::${var.data_bucket}${grant.path}*"
      ]
    }
EOF2
  ]
)}
  ]
}
POLICY
}
