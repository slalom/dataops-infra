locals {
  source_files = toset([
    for f in fileset(var.local_metadata_path, "*") :
    f
    if length([
      for tap_name in local.taps_specs.*.name :
      tap_name
      if replace(f, tap_name, "") != f
    ]) > 0
  ])
  source_files_hash = join(",", [
    for filepath in local.source_files :
    filebase64sha256("${var.local_metadata_path}/${filepath}")
  ])
  unique_hash   = md5(local.source_files_hash)
  unique_suffix = substr(local.unique_hash, 0, 4)
}

resource "aws_s3_bucket_object" "s3_source_uploads" {
  for_each = local.source_files
  # Parse the S3 path into 'bucket' and 'key' values:
  # https://gist.github.com/aaronsteers/19eb4d6cba926327f8b25089cb79259b
  bucket = split("/", split("//", var.data_lake_metadata_path)[1])[0]
  key = join("/",
    [
      join("/", slice(
        split("/", split("//", var.data_lake_metadata_path)[1]),
        1,
        length(split("/", split("//", var.data_lake_metadata_path)[1]))
      )),
      "tap-snapshot-${local.unique_suffix}/${each.value}"
    ]
  )
  source   = "${var.local_metadata_path}/${each.value}"
  tags     = var.resource_tags
  metadata = {}
  # etag     = filebase64sha256("${var.local_metadata_path}/${each.value}")
}
