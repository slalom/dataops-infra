resource "random_id" "suffix" { byte_length = 2 }

data "aws_s3_bucket" "ml_bucket_override" {
  count  = var.ml_bucket_override != null ? 1 : 0
  bucket = var.ml_bucket_override
}

locals {
  random_bucket_suffix = lower(random_id.suffix.dec)
  ml_bucket            = var.ml_bucket_override != null ? data.aws_s3_bucket.ml_bucket_override[0].id : aws_s3_bucket.ml_bucket[0].id
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

resource "aws_s3_bucket" "ml_bucket" {
  count  = var.ml_bucket_override == null ? 1 : 0
  bucket = "${lower(var.name_prefix)}ml-bucket-${local.random_bucket_suffix}"
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
  for_each     = substr(strrev(var.train_local_path), 0, 1) == "/" ? fileset(var.train_local_path, "*.*") : [var.train_local_path]
  bucket       = var.ml_bucket_override != null ? data.aws_s3_bucket.ml_bucket_override[0].id : aws_s3_bucket.ml_bucket[0].id
  key          = substr(strrev(var.train_key), 0, 1) == "/" ? "${var.train_key}${basename(each.value)}" : var.train_key
  source       = abspath(each.value)
  content_type = var.input_data_content_type
}

resource "aws_s3_bucket_object" "test_data" {
  for_each     = substr(strrev(var.score_local_path), 0, 1) == "/" ? fileset(var.score_local_path, "*.*") : [var.score_local_path]
  bucket       = var.ml_bucket_override != null ? data.aws_s3_bucket.ml_bucket_override[0].id : aws_s3_bucket.ml_bucket[0].id
  key          = substr(strrev(var.score_key), 0, 1) == "/" ? "${var.score_key}${basename(each.value)}" : var.score_key
  source       = abspath(each.value)
  content_type = var.input_data_content_type
}

resource "aws_s3_bucket_object" "glue_script" {
  bucket = aws_s3_bucket.source_repository.id
  key    = "glue/transform.py"
  source = var.glue_transform_script

  etag = filemd5(
    var.glue_transform_script,
  )
}

resource "aws_s3_bucket_object" "glue_python_lib" {
  bucket = aws_s3_bucket.source_repository.id
  key    = "glue/python/pandasmodule-0.1-py3-none-any.whl"
  source = var.glue_dependency_package

  etag = filemd5(
    var.glue_dependency_package,
  )
}
