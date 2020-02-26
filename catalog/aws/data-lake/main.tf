resource "random_id" "suffix" {
  byte_length = 2
}

locals {
  s3_path_to_lambda_zip = "s3://${aws_s3_bucket.s3_metadata_bucket.bucket}/code/lambda/${var.name_prefix}lambda.zip"
  random_bucket_suffix  = lower(random_id.suffix.hex)
}

resource "aws_s3_bucket" "s3_data_bucket" {
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
  source                = "../../../components/aws/lambda-python"
  name_prefix           = var.name_prefix
  environment           = var.environment
  s3_trigger_bucket     = aws_s3_bucket.s3_data_bucket.bucket
  s3_triggers           = var.s3_triggers
  lambda_source_folder  = var.lambda_python_source
  s3_path_to_lambda_zip = local.s3_path_to_lambda_zip
  resource_tags         = var.resource_tags

  # depends_on = [
  #   aws_s3_bucket.s3_data_bucket,
  #   aws_s3_bucket.s3_logging_bucket,
  #   aws_s3_bucket.s3_metadata_bucket
  # ]
}
