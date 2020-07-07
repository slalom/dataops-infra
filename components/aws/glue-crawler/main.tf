/*
* Glue is AWS's fully managed extract, transform, and load (ETL) service. 
* A Glue crawler is used to access a data store and create table definitions. 
* This can be used in conjuction with Amazon Athena to query flat files in S3 buckets using SQL.
*/

resource "aws_glue_catalog_database" "glue_database" {
  name = var.glue_database_name
}

resource "aws_glue_crawler" "glue_crawler" {
  database_name = aws_glue_catalog_database.glue_database.name
  name          = var.glue_crawler_name
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    path = "s3://${var.s3_target_bucket_name}/${var.target_path}"
  }
}
