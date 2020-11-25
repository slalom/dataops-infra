# data "http" "additional_reqs" {
#   for_each = var.dependency_urls
#   url      = each.value
# }

# resource "local_file" "additional_reqs_local" {
#   for_each = var.dependency_urls
#   filename = "${local.temp_build_folder}/${each.key}"
#   content  = data.http.additional_reqs[each.value].content
# }

# Step 1: Copy Files to temp directory

resource "local_file" "canary_file" {
  content  = local.temp_build_folder
  filename = "${local.temp_build_folder}/foo.bar"
}

# Step 2: Run `pip install` from within temp directory

resource "null_resource" "pip" {
  # count = fileexists("${var.lambda_source_folder}/requirements.txt") ? 1 : 0

  # Prepares Lambda package (https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204)
  triggers = {
    version_increment = 1.2 # used to force a refresh
    # not_exists        = fileexists("${var.lambda_source_folder}/requirements.txt")
    source_folder     = abspath(var.lambda_source_folder)
    source_file_list  = join(",", fileset(var.lambda_source_folder, "*"))
    source_files_hash = local.source_files_hash
    temp_build_folder = local.temp_build_folder
  }
  provisioner "local-exec" {
    command = join(" && ", flatten(
      [
        [
          # Copy files to temp directory
          local.is_windows ?
          [
            "if not exist ${replace(local.temp_build_folder, "/", "\\")}\\NUL mkdir ${replace(local.temp_build_folder, "/", "\\")}",
            "copy ${replace(var.lambda_source_folder, "/", "\\")}\\* ${replace(local.temp_build_folder, "/", "\\")}\\",
          ] :
          [
            "mkdir -p ${local.temp_build_folder}",
            "cp ${var.lambda_source_folder}/* ${local.temp_build_folder}/",
          ]
        ],
        # Run `pip install` to compile dependencies
        "${var.pip_path} install --upgrade -r ${var.lambda_source_folder}/requirements.txt --target ${local.temp_build_folder}"
      ]
    ))
  }
  depends_on = [local_file.canary_file]
}

# # Step 3: Wait for things to finish

# data "null_data_source" "wait_for_lambda_exporter" {
#   # Workaround for explicit 'depends' issue within archive_file provider: https://github.com/terraform-providers/terraform-provider-archive/issues/11
#   inputs = {
#     # This ensures that this data resource will not be evaluated until
#     # after the null_resource has been created.
#     lambda_exporter_id = fileexists("${var.lambda_source_folder}/requirements.txt") ? null_resource.pip.id : null
#     copy_files_id      = null_resource.copy_files.id

#     # This value gives us something to implicitly depend on
#     # in the archive_file below.
#     source_dir = "${local.temp_build_folder}/"
#   }
#   depends_on = [null_resource.copy_files]
# }

# Step 4: Create a packaged zip of the temp directory

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = null_resource.pip.id == "dummy" ? local.temp_build_folder : local.temp_build_folder
  output_path = replace(local.zip_local_path, ".zip", "-${null_resource.pip.id}.zip")
  depends_on  = [null_resource.pip, local_file.canary_file]
}

# Step 5: Optionally upload the zip file to S3

resource "aws_s3_bucket_object" "s3_lambda_zip" {
  count = var.upload_to_s3 ? 1 : 0
  # Parse the S3 path into 'bucket' and 'key' values:
  # https://gist.github.com/aaronsteers/19eb4d6cba926327f8b25089cb79259b
  bucket = split("/", split("//", var.upload_to_s3_path)[1])[0]
  key = join("/", slice(
    split("/", split("//", var.upload_to_s3_path)[1]),
    1,
    length(split("/", split("//", var.upload_to_s3_path)[1]))
  ))
  source = data.archive_file.lambda_zip.output_path
  etag   = data.archive_file.lambda_zip.output_md5
}
