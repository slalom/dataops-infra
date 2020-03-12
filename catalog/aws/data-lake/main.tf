resource "random_id" "suffix" { byte_length = 2 }

data aws_s3_bucket "data_bucket_override" {
  count  = var.data_bucket_override != null ? 1 : 0
  bucket = var.data_bucket_override
}

locals {
  s3_path_to_lambda_zip = "s3://${aws_s3_bucket.s3_metadata_bucket.id}/code/lambda/${var.name_prefix}lambda.zip"
  random_bucket_suffix  = lower(random_id.suffix.hex)
  data_bucket_name = (
    var.data_bucket_override != null ? data.aws_s3_bucket.data_bucket_override[0].id : aws_s3_bucket.s3_data_bucket[0].id
  )
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
  source        = "../../../components/aws/lambda-python"
  name_prefix   = var.name_prefix
  resource_tags = var.resource_tags
  environment   = var.environment

  runtime              = "python3.8"
  lambda_source_folder = var.lambda_python_source
  upload_to_s3         = true
  upload_to_s3_path    = local.s3_path_to_lambda_zip

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
