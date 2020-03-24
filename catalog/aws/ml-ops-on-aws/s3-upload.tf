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
