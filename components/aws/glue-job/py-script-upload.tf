resource "aws_s3_bucket_object" "py_script_upload" {
  count  = var.local_script_path == null ? 0 : 1
  bucket = var.s3_script_bucket_name
  key    = "glue/py-scripts/${filemd5(var.local_script_path)}-${basename(var.local_script_path)}"
  source = var.local_script_path
}
