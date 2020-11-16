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
  count = local.is_disabled ? 0 : (fileexists("${var.lambda_source_folder}/requirements.txt") ? 1 : 0)

  # Prepares Lambda package (https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204)
  triggers = {
    version_increment = 1.2
    requirements_hash = try(filebase64sha256("${var.lambda_source_folder}/requirements.txt"), "n/a")
    output_path       = local.temp_build_folder
    temp_build_folder = local.temp_build_folder
  }
  provisioner "local-exec" {
    command = "${var.pip_path} install --upgrade -r ${var.lambda_source_folder}/requirements.txt --target ${local.temp_build_folder}"
  }
}

resource "null_resource" "copy_files" {
  count = local.is_disabled ? 0 : 1

  # Prepares Lambda package (https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204)
  triggers = {
    version_increment = 1.3
    source_file_list  = join(",", fileset(var.lambda_source_folder, "*"))
    source_files_hash = local.source_files_hash
    output_path       = local.temp_build_folder
    temp_build_folder = local.temp_build_folder
  }
  provisioner "local-exec" {
    command = (
      local.is_windows ?
      "if not exist ${replace(local.temp_build_folder, "/", "\\")}\\NUL mkdir ${replace(local.temp_build_folder, "/", "\\")} && copy ${replace(var.lambda_source_folder, "/", "\\")}\\* ${replace(local.temp_build_folder, "/", "\\")}\\" :
      "mkdir -p ${local.temp_build_folder} && cp ${var.lambda_source_folder}/* ${local.temp_build_folder}/"
    )
  }
}

data "null_data_source" "wait_for_lambda_exporter" {
  count = local.is_disabled ? 0 : 1

  # Workaround for explicit 'depends' issue within archive_file provider: https://github.com/terraform-providers/terraform-provider-archive/issues/11
  inputs = {
    # This ensures that this data resource will not be evaluated until
    # after the null_resource has been created.
    lambda_exporter_id = fileexists("${var.lambda_source_folder}/requirements.txt") ? null_resource.pip[0].id : null
    copy_files_id      = null_resource.copy_files[0].id

    # This value gives us something to implicitly depend on
    # in the archive_file below.
    source_dir = "${local.temp_build_folder}/"
  }
}

data "archive_file" "lambda_zip" {
  count       = local.is_disabled ? 0 : 1
  type        = "zip"
  source_dir  = data.null_data_source.wait_for_lambda_exporter[0].outputs["source_dir"]
  output_path = local.zip_local_path
  depends_on  = [null_resource.pip, null_resource.copy_files]
}

resource "aws_s3_bucket_object" "s3_lambda_zip" {
  count = (var.upload_to_s3 && (local.is_disabled == false)) ? 1 : 0
  # Parse the S3 path into 'bucket' and 'key' values:
  # https://gist.github.com/aaronsteers/19eb4d6cba926327f8b25089cb79259b
  bucket = split("/", split("//", var.upload_to_s3_path)[1])[0]
  key = join("/", slice(
    split("/", split("//", var.upload_to_s3_path)[1]),
    1,
    length(split("/", split("//", var.upload_to_s3_path)[1]))
  ))
  source = data.archive_file.lambda_zip[0].output_path
  etag   = data.archive_file.lambda_zip[0].output_md5
}
