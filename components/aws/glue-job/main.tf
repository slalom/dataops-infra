/*
* Glue is AWS's fully managed extract, transform, and load (ETL) service. A Glue job can be used job to run ETL Python scripts.
*
*
*/

locals {
  # Reusable TF Snippet to parse S3 path into bucket+key: https://gist.github.com/aaronsteers/19eb4d6cba926327f8b25089cb79259b
  s3_script_bucket_name = split("/", split("//", var.s3_script_path)[1])[0]
  s3_script_key = join("/", slice(
    split("/", split("//", var.s3_script_path)[1]),
    1,
    length(split("/", split("//", var.s3_script_path)[1]))
  ))
}

resource "aws_glue_job" "glue_job" {
  name         = "${var.name_prefix}data-transformation"
  role_arn     = aws_iam_role.glue_job_role.arn
  tags         = var.resource_tags
  glue_version = "1.0"
  max_capacity = 1

  command {
    script_location = var.s3_script_path
    name            = var.use_spark ? "pyspark" : "python"
    python_version  = 3 # Major version only. Allowed values are: 2 or 3
  }
}
