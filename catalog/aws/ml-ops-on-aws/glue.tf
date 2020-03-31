module "glue_job" {
  source        = "../../../components/aws/glue"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  job_type                   = var.glue_job_type
  s3_source_bucket_name      = var.feature_store_name
  s3_destination_bucket_name = var.extracts_store_name
  script_path                = "${var.job_name}/glue/transform.py"
}