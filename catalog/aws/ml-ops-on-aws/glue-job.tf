module "glue_job" {
  source        = "../../../components/aws/glue-job"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  job_type                   = var.glue_job_type
  s3_script_bucket_name      = aws_s3_bucket.source_repository.id
  s3_source_bucket_name      = var.feature_store_override != null ? data.aws_s3_bucket.feature_store_override[0].id : aws_s3_bucket.feature_store[0].id
  s3_destination_bucket_name = aws_s3_bucket.extracts_store.id
  script_path                = "${var.job_name}/glue/transform.py"
}