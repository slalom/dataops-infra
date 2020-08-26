module "glue_job" {
  source        = "../../../components/aws/glue-job"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  with_spark                 = var.glue_job_spark_flag
  s3_script_bucket_name      = aws_s3_bucket.source_repository.id
  s3_source_bucket_name      = var.ml_bucket_override != null ? data.aws_s3_bucket.ml_bucket_override[0].id : aws_s3_bucket.ml_bucket[0].id
  s3_destination_bucket_name = aws_s3_bucket.ml_bucket[0].id
  s3_script_path             = "glue/transform.py"
}
