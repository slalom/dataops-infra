/*
* Automates the management of users and groups in an S3 data lake.
*
* * Designed to be used in combination with the `aws/data-lake` module.
*
*/

data "aws_s3_bucket" "data_bucket" { bucket = var.data_bucket }

locals {
  group_names = toset(
    flatten([
      keys(var.group_permissions),
      flatten(values(var.user_groups))
    ])
  )
}

resource "aws_kms_key" "group_kms_keys" {
  for_each                = local.group_names
  description             = "${var.name_prefix}${each.value}-kms"
  deletion_window_in_days = 10
}
resource "aws_kms_alias" "group_kms_key_alias" {
  for_each      = local.group_names
  name          = "alias/${var.name_prefix}${each.value}-kms"
  target_key_id = aws_kms_key.group_kms_keys[each.value].key_id
}
