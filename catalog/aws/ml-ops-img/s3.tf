resource "random_id" "suffix" { byte_length = 2 }

data aws_s3_bucket "feature_store_override" {
  count  = var.feature_store_override != null ? 1 : 0
  bucket = var.feature_store_override
}

locals {
  random_bucket_suffix = lower(random_id.suffix.dec)
  feature_store_bucket = (
    var.feature_store_override != null ? data.aws_s3_bucket.feature_store_override[0].id : aws_s3_bucket.feature_store[0].id
  )
}

resource "aws_s3_bucket" "source_repository" {
  bucket = "${lower(var.name_prefix)}source-repository-${local.random_bucket_suffix}"
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

resource "aws_s3_bucket" "feature_store" {
  count  = var.feature_store_override == null ? 1 : 0
  bucket = "${lower(var.name_prefix)}feature-store-${local.random_bucket_suffix}"
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

resource "aws_s3_bucket" "data_store" {
  bucket = "${lower(var.name_prefix)}extracts-store-${local.random_bucket_suffix}"
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

resource "aws_s3_bucket" "model_store" {
  bucket = "${lower(var.name_prefix)}model-store-${local.random_bucket_suffix}"
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

resource "aws_s3_bucket_object" "train_data" {
  bucket       = var.feature_store_override != null ? data.aws_s3_bucket.feature_store_override[0].id : aws_s3_bucket.feature_store[0].id
  key          = "input_data/train"
  source       = var.train_local_path
  content_type = "application/x-recordio"
  for_each = fileset(
    var.train_local_path, "input_data/train/*.png"
  )
}

resource "aws_s3_bucket_object" "score_data" {
  bucket       = var.feature_store_override != null ? data.aws_s3_bucket.feature_store_override[0].id : aws_s3_bucket.feature_store[0].id
  key          = "input_data/score"
  source       = var.score_local_path
  content_type = "application/x-recordio"
  for_each = fileset(
    var.score_local_path, "input_data/score/*.png"
  )
}

resource "aws_s3_bucket_object" "glue_script" {
  bucket = aws_s3_bucket.source_repository.id
  key    = "glue/transform.py"
  source = var.script_path

  etag = filemd5(
    var.script_path,
  )
}

resource "aws_s3_bucket_object" "glue_python_lib" {
  bucket = aws_s3_bucket.source_repository.id
  key    = "glue/python/pandasmodule-0.1-py3-none-any.whl"
  source = var.whl_path

  etag = filemd5(
    var.whl_path,
  )
}
