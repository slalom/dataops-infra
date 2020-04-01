resource "aws_s3_bucket_object" "train_data" {
  bucket = var.feature_store_name
  key    = "${var.job_name}/data/train/train.csv"
  source = var.train_local_path

  etag = filemd5(
    var.train_local_path,
  )
}

resource "aws_s3_bucket_object" "score_data" {
  bucket = var.feature_store_name
  key    = "${var.job_name}/data/score/score.csv"
  source = var.score_local_path

  etag = filemd5(
    var.score_local_path,
  )
}

resource "aws_s3_bucket_object" "glue_script" {
  bucket = var.source_repository_name
  key    = "${var.job_name}/glue/transform.py"
  source = var.script_path

  etag = filemd5(
    var.script_path,
  )
}

resource "aws_s3_bucket_object" "glue_python_lib" {
  bucket = var.source_repository_name
  key    = "${var.job_name}/glue/python/pandasmodule-0.1-py3-none-any.whl"
  source = var.whl_path

  etag = filemd5(
    var.whl_path,
  )
}