# OPTIONAL: Only if using 'bring your own model'

module "glue_job" {
  source        = "../../../components/aws/glue"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  job_name       = var.glue_job_name
  job_type       = var.glue_job_type
  s3_bucket_name = var.s3_bucket_name
  script_path    = "glue/transform.py"
}