locals {
  source_files = toset([
    for f in fileset(var.local_metadata_path, "*") :
    f
    if replace(f, var.taps[0].id, "") != f
  ])
  source_files_hash = join(",", [
    for filepath in local.source_files :
    filebase64sha256("${var.local_metadata_path}/${filepath}")
  ])
  unique_hash = md5(local.source_files_hash)
}

resource "aws_s3_bucket_object" "s3_source_uploads" {
  for_each = local.source_files
  # https://gist.github.com/aaronsteers/19eb4d6cba926327f8b25089cb79259b
  # Parse the S3 path into 'bucket' and 'key' values:
  bucket = split("/", split("//", var.data_lake_metadata_path)[1])[0]
  key = join("/",
    [
      join("/", slice(
        split("/", split("//", var.data_lake_metadata_path)[1]),
        1,
        length(split("/", split("//", var.data_lake_metadata_path)[1]))
      )),
      "tap-snapshot-${local.unique_hash}/${each.value}"
    ]
  )
  source   = "${var.local_metadata_path}/${each.value}"
  tags     = var.resource_tags
  metadata = {}
  # etag     = filebase64sha256("${var.local_metadata_path}/${each.value}")
}
