/*
* Glue is AWS's fully managed extract, transform, and load (ETL) service. A Glue job can be used job to run ETL Python scripts.
*/

resource "aws_glue_job" "glue_job" {
  name         = "${var.name_prefix}data-transformation"
  role_arn     = aws_iam_role.glue_ml_ops_role.arn
  tags         = var.resource_tags
  glue_version = "1.0"
  max_capacity = 1

  command {
    script_location = "s3://${var.s3_source_bucket_name}/${var.script_path}"
    name            = var.job_type
    python_version  = 3
  }
}
