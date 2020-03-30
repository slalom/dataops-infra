resource "aws_s3_bucket_object" "train_data" {
  bucket = var.s3_bucket_name
  key    = "${var.data_s3_path}/train/train.csv"
  source = "${var.data_folder}/train.csv"

  etag = filemd5(
    "${var.data_folder}/train.csv",
  )
}

resource "aws_s3_bucket_object" "test_data" {
  bucket = var.s3_bucket_name
  key    = "${var.data_s3_path}/test/test.csv"
  source = "${var.data_folder}/test.csv"

  etag = filemd5(
    "${var.data_folder}/test.csv",
  )
}

resource "aws_s3_bucket_object" "glue_script" {
  bucket = var.s3_bucket_name
  key    = "glue/transform.py"
  source = "${var.script_folder}/transform.py"

  etag = filemd5(
    "${var.script_folder}/transform.py",
  )
}

resource "aws_s3_bucket_object" "glue_python_lib" {
  bucket = var.s3_bucket_name
  key    = "glue/python/pandasmodule-0.1-py3-none-any.whl"
  source = "${var.script_folder}/python/pandasmodule-0.1-py3-none-any.whl"

  etag = filemd5(
    "${var.script_folder}/python/pandasmodule-0.1-py3-none-any.whl",
  )
}