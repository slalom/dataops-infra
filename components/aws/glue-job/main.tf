/*
* Glue is AWS's fully managed extract, transform, and load (ETL) service. A Glue job can be used job to run ETL Python scripts.
*/

resource "aws_glue_job" "glue_job" {
  name         = "${var.name_prefix}data-transformation"
  role_arn     = aws_iam_role.glue_job_role.arn
  tags         = var.resource_tags
  glue_version = "1.0"
  max_capacity = 1

  command {
    script_location = (
      var.local_script_path == null ?
      "s3://${var.s3_script_bucket_name}/${var.s3_script_path}" :
      "s3://${aws_s3_bucket_object.py_script_upload[0].bucket}/${aws_s3_bucket_object.py_script_upload[0].key}"
    )
    name           = var.with_spark ? null : "pythonshell"
    python_version = var.with_spark ? null : 3
  }
}
