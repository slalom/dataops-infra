locals {
  source_files = fileset(var.source_code_folder, "*")
  source_files_hash = join(",", [
    for filepath in local.source_files :
    filebase64sha256("${var.source_code_folder}/${filepath}")
  ])
  unique_hash = md5(local.source_files_hash)
}

resource "aws_s3_bucket_object" "s3_source_uploads" {
  for_each = local.source_files
  bucket   = var.source_code_s3_bucket
  key      = "${var.source_code_s3_path}/tap-snapshot-${local.unique_hash}/${each.value}"
  source   = "${var.source_code_folder}/${each.value}"
  # etag     = filebase64sha256("${var.source_code_folder}/${each.value}")
}
