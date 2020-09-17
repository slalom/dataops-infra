locals {
  # Parse the S3 path into 'bucket' and 'key' values:
  # https://gist.github.com/aaronsteers/19eb4d6cba926327f8b25089cb79259b
  data_lake_storage_bucket = var.data_lake_storage_path == null ? null : split("/", split("//", var.data_lake_storage_path)[1])[0]
  data_lake_storage_key_prefix = var.data_lake_storage_path == null ? null : join("/", [
    join("/", slice(
      split("/", split("//", var.data_lake_storage_path)[1]),
      1,
      length(split("/", split("//", var.data_lake_storage_path)[1]))
    )),
    replace(var.data_file_naming_scheme, "{file}", "")
  ])
}
