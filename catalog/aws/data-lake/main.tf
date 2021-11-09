/*
* This data lake implementation creates three buckets, one each for data, logging, and metadata. The data lake also supports lambda functions which can
* trigger automatically when new content is added.
*
* * Designed to be used in combination with the `aws/data-lake-users` module.
* * To add SFTP protocol support, combine this module with the `aws/sftp` module.
*
*/

resource "random_id" "suffix" { byte_length = 2 }

data "aws_s3_bucket" "data_bucket_override" {
  count  = var.data_bucket_override != null ? 1 : 0
  bucket = var.data_bucket_override
}

locals {
  # Removing the /lambda/ prefix to lambda zip path for webhooks
  # s3_path_to_lambda_zip = "s3://${aws_s3_bucket.s3_metadata_bucket.id}/code/lambda/${var.name_prefix}lambda.zip"
  s3_path_to_lambda_zip = "s3://${aws_s3_bucket.s3_metadata_bucket.id}/code/${var.name_prefix}lambda.zip"
  random_bucket_suffix  = lower(random_id.suffix.dec)
  data_bucket_name      = var.data_bucket_override != null ? data.aws_s3_bucket.data_bucket_override[0].id : aws_s3_bucket.s3_data_bucket[0].id
}

resource "aws_s3_bucket" "s3_data_bucket" {
  count  = var.data_bucket_override == null ? 1 : 0
  bucket = "${lower(var.name_prefix)}data-${local.random_bucket_suffix}"
  acl    = "private"
  tags   = var.resource_tags
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "s3_metadata_bucket" {
  bucket = "${lower(var.name_prefix)}meta-${local.random_bucket_suffix}"
  acl    = "private"
  tags   = var.resource_tags
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "s3_logging_bucket" {
  bucket = "${lower(var.name_prefix)}logs-${local.random_bucket_suffix}"
  acl    = "private"
  tags   = var.resource_tags
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

module "triggered_lambda" {
  count         = length(var.s3_triggers) > 0 ? 1 : 0
  source        = "../../../components/aws/lambda-python"
  name_prefix   = var.name_prefix
  resource_tags = var.resource_tags
  environment   = var.environment

  runtime              = "python3.8"
  lambda_source_folder = var.lambda_python_source
  s3_upload_path       = local.s3_path_to_lambda_zip
  pip_path             = var.pip_path

  functions = {
    for name, def in var.s3_triggers :
    name => {
      description = "'${name}' trigger for data lake events"
      handler     = def.lambda_handler
      environment = def.environment_vars
      secrets     = def.environment_secrets
    }
  }
  s3_triggers = [
    for name, trigger in var.s3_triggers :
    {
      function_name = name
      s3_bucket     = local.data_bucket_name
      s3_path       = trigger.triggering_path
    }
  ]
}
