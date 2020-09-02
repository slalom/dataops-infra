output "glue_job1_summary" { value = module.glue_job1.summary }
module "glue_job1" {
  source        = "../../components/aws/glue-job"
  name_prefix   = "${local.name_prefix}1-"
  environment   = module.env.environment
  resource_tags = local.resource_tags

  s3_script_bucket_name      = module.data_lake.s3_metadata_bucket
  s3_source_bucket_name      = module.data_lake.s3_data_bucket  # Source data location
  s3_destination_bucket_name = module.data_lake.s3_data_bucket  # Output data location
  local_script_path          = "${path.module}/glue/hello/hello_world.py"
  s3_script_path             = "${path.module}/glue/hello/hello_world.py"
  with_spark                 = true
}

output "glue_job2_summary" { value = module.glue_job2.summary }
module "glue_job2" {
  source        = "../../components/aws/glue-job"
  name_prefix   = "${local.name_prefix}2-"
  environment   = module.env.environment
  resource_tags = local.resource_tags

  s3_script_bucket_name      = module.data_lake.s3_metadata_bucket
  s3_source_bucket_name      = module.data_lake.s3_data_bucket  # Source data location
  s3_destination_bucket_name = module.data_lake.s3_data_bucket  # Output data location
  local_script_path          = "${path.module}/glue/transform/transform.py"
  s3_script_path             = "${path.module}/glue/transform/transform.py"
  with_spark                 = true

  default_arguments = {
    "--S3_DATA_BUCKET" = module.data_lake.s3_data_bucket
  }
}
