resource "aws_iam_group" "data_lake_user_groups" {
  for_each = local.group_names
  name     = each.value
  path     = "/${var.name_prefix}groups/"
}
resource "aws_iam_user" "new_users" {
  for_each      = var.users
  name          = each.value
  path          = "/"
  force_destroy = true
}
resource "aws_iam_access_key" "user_keys" {
  for_each = var.users
  user     = aws_iam_user.new_users[each.value].name
  pgp_key  = "keybase:${var.admin_keybase_id}"
}
resource "aws_iam_group_membership" "group_membership" {
  for_each = local.group_names
  name     = "${var.name_prefix}${each.value}-membership"
  users = toset([
    for user, group_list in var.user_groups :
    aws_iam_user.new_users[user].name
    if contains(group_list, each.value)
  ])
  group = aws_iam_group.data_lake_user_groups[each.value].name
}
resource "local_file" "encrypted_secret_key_files" {
  for_each = var.users
  filename = "${local.temp_artifacts_root}/${each.value}-encrypted-secret.txt"
  content  = <<EOF
-----BEGIN PGP MESSAGE-----
Version: Keybase OpenPGP v2.1.13
Comment: https://keybase.io/crypto

${aws_iam_access_key.user_keys[each.value].encrypted_secret}
-----END PGP MESSAGE-----
EOF
}

resource "aws_iam_policy" "group_s3_permission" {
  for_each = var.group_permissions
  name     = "${var.name_prefix}${each.key}-s3access"
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
      "Sid": "AllowListingRoot",
      "Action": ["s3:ListBucket"],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::${var.data_bucket}"],
      "Condition":{"StringEquals":{"s3:prefix":[""],"s3:delimiter":["/"]}}
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
    {
      "Sid": "AllowUseOfGroupKmsKey",
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ],
      "Resource": ["${aws_kms_key.group_kms_keys[each.key].arn}"]
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
    },
    {
      "Sid": "AllowS3ListingON${replace(replace(replace(grant.path, "/", ""), "-", ""), "_", "")}",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${var.data_bucket}"],
      ${grant.path == "" ? "" : <<EOF
"Condition":{"StringEquals":{"s3:prefix":["${grant.path}"],"s3:delimiter":["/"]}},
EOF
  }
      "Effect": "Allow"
    }
EOF2
]
)}
  ]
}
POLICY
}

resource "aws_iam_group_policy_attachment" "group_s3_policy_attachments" {
  for_each   = local.group_names
  group      = aws_iam_group.data_lake_user_groups[each.value].name
  policy_arn = aws_iam_policy.group_s3_permission[each.value].arn
}
