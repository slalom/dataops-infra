module "glue_crawler" {
  source        = "../../../components/aws/glue-crawler"
  name_prefix   = var.name_prefix
  environment   = var.environment
  resource_tags = var.resource_tags

  glue_database_name    = "${var.name_prefix}database"
  glue_crawler_name     = "${var.name_prefix}glue-crawler"
  s3_target_bucket_name = aws_s3_bucket.data_store.id
  target_path           = "batch-transform-output/"
}
