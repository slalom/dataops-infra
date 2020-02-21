# data "http" "additional_reqs" {
#   for_each = var.dependency_urls
#   url      = each.value
# }

# resource "local_file" "additional_reqs_local" {
#   for_each = var.dependency_urls
#   filename = "${local.temp_build_folder}/${each.key}"
#   content  = data.http.additional_reqs[each.value].content
# }

resource "null_resource" "pip" {
  # Prepares Lambda package (https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204)
  triggers = {
    version_increment = 1.1
    requirements_hash = filebase64sha256("${var.lambda_source_folder}/requirements.txt")
    output_path = local.temp_build_folder
  }
  provisioner "local-exec" {
    command = "${var.pip_path} install --upgrade -r ${var.lambda_source_folder}/requirements.txt --target ${local.temp_build_folder}"
  }
}

resource "null_resource" "copy_files" {
  # Prepares Lambda package (https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204)
  triggers = {
    version_increment = 1.1
    source_file_list = join(",", fileset(var.lambda_source_folder, "*"))
    source_files_hash = join(",", [
      for filepath in fileset(var.lambda_source_folder, "*") :
      filebase64sha256("${var.lambda_source_folder}/${filepath}")
    ])
    output_path = local.temp_build_folder
  }
  provisioner "local-exec" {
    command = (
      local.is_windows ?
      "copy ${replace(var.lambda_source_folder, "/", "\\")}\\* ${replace(local.temp_build_folder, "/", "\\")}" :
      "cp ${var.lambda_source_folder}/* ${local.temp_build_folder}"
    )
  }
}

data "null_data_source" "wait_for_lambda_exporter" {
  # Workaround for explicit 'depends' issue within archive_file provider: https://github.com/terraform-providers/terraform-provider-archive/issues/11
  inputs = {
    # This ensures that this data resource will not be evaluated until
    # after the null_resource has been created.
    lambda_exporter_id = "${null_resource.pip.id}"
    copy_files_id      = "${null_resource.copy_files.id}"

    # This value gives us something to implicitly depend on
    # in the archive_file below.
    source_dir = "${local.temp_build_folder}/"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = data.null_data_source.wait_for_lambda_exporter.outputs["source_dir"]
  output_path = local.zip_local_path
}

resource "aws_s3_bucket_object" "s3_lambda_zip" {
  bucket = split("/", split("//", var.s3_path_to_lambda_zip)[1])[0]
  key = join("/", slice(
    split("/", split("//", var.s3_path_to_lambda_zip)[1]),
    1,
    length(split("/", split("//", var.s3_path_to_lambda_zip)[1]))
  ))
  source = data.archive_file.lambda_zip.output_path
  etag   = data.archive_file.lambda_zip.output_md5
}
