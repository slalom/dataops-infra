# resource "local_file" "canary_file" {
#   content  = local.temp_build_folder
#   filename = "${local.temp_build_folder}/foo.bar"
# }

# resource "null_resource" "create_source_zip" {
#   # Prepares Lambda package (https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204)
#   triggers = {
#     version_increment = 1.0 # can be incremented to force a refresh
#     source_files_hash = local.source_files_hash
#   }
#   provisioner "local-exec" {
#     interpreter = local.is_windows ? ["Powershell", "-Command"] : ["/bin/bash", "-c"]
#     command = join(local.is_windows ? "; " : " && ", flatten(
#       # local.local_requirements_file == null ? [] :
#       local.is_windows ?
#       [
#         "echo \"Creating zip file '${local.local_source_zip_path}'...\"",
#         "icacls ${local.local_source_zip_path} /grant Everyone:F",
#         "icacls ${local.local_source_zip_path}/* /grant Everyone:F",
#         "Compress-Archive -Force -Path ${var.lambda_source_folder}/* -DestinationPath ${local.local_source_zip_path}",
#       ] :
#       [
#         "echo \"Creating zip file '${local.local_source_zip_path}'...\"",
#         "set -e",
#         "chmod -R 755 ${local.temp_build_folder}",
#         "zip -r ${local.local_source_zip_path} ${var.lambda_source_folder}"
#       ]
#     ))
#   }
# }

resource "null_resource" "create_dependency_zip" {
  count = 1 # count = local.local_requirements_file == null ? 0 : 1
  # Prepares Lambda package (https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204)
  triggers = {
    version_increment = 1.1 # can be incremented to force a refresh
    source_files_hash = local.source_files_hash
  }

  provisioner "local-exec" {
    interpreter = local.is_windows ? ["Powershell", "-Command"] : ["/bin/bash", "-c"]
    command = join(local.is_windows ? "; " : " && ", flatten(
      # local.local_requirements_file == null ? [] :
      local.is_windows ?
      [
        [
          "echo \"Creating target directory '${abspath(local.temp_build_folder)}'...\"",
          "New-Item -ItemType Directory -Force -Path ${abspath(local.temp_build_folder)}",
          # "copy ${local.local_requirements_file} ${local.temp_build_folder}/requirements.txt",
          "echo \"Copying directory contents from '${abspath(var.lambda_source_folder)}/' to '${abspath(local.temp_build_folder)}/'...\"",
          "Copy-Item -Force -Recurse -Path \"${abspath(var.lambda_source_folder)}/*\" -Destination \"${abspath(local.temp_build_folder)}/\"",
          "echo \"Granting execute permissions on temp folder '${local.temp_build_folder}'\"",
          "icacls ${local.temp_build_folder} /grant Everyone:F",
          "icacls ${local.temp_build_folder}/* /grant Everyone:F",
        ],
        local.local_requirements_file == null ? [] : !fileexists(local.local_requirements_file) ? [] :
        [
          "echo \"Running pip install from requirements '${abspath(local.local_requirements_file)}'...\"",
          "${local.pip_path} install --upgrade -r ${abspath(local.local_requirements_file)} --target ${local.temp_build_folder}",
        ],
        [
          "sleep 3",
          "echo \"Changing working directory to temp folder '${abspath(local.temp_build_folder)}'...\"",
          "cd ${abspath(local.temp_build_folder)}",
          "echo \"Zipping contents of ${abspath(local.temp_build_folder)} to '${abspath(local.local_dependencies_zip_path)}'...\"",
          "ls",
          "tar -acf ${abspath(local.local_dependencies_zip_path)} *",
          # "Compress-Archive -Force -Path ${local.temp_build_folder}/* -DestinationPath ${local.local_dependencies_zip_path}",
        ]
      ] :
      [
        [
          "echo \"Creating target directory '${abspath(local.temp_build_folder)}'...\"",
          "set -e",
          "mkdir -p ${local.temp_build_folder}",
          "echo \"Copying directory contents from '${abspath(var.lambda_source_folder)}/' to '${abspath(local.temp_build_folder)}/'...\"",
          "cp ${var.lambda_source_folder}/* ${local.temp_build_folder}/",
        ],
        local.local_requirements_file == null ? [] : !fileexists(local.local_requirements_file) ? [] :
        [
          "echo \"Running pip install from requirements '${abspath(local.local_requirements_file)}'...\"",
          "${local.pip_path} install --upgrade -r ${local.temp_build_folder}/requirements.txt --target ${local.temp_build_folder}",
        ],
        [
          "sleep 3",
          "echo \"Granting execute permissions on temp folder '${local.temp_build_folder}'\"",
          "chmod -R 755 ${local.temp_build_folder}",
          "cd ${abspath(local.temp_build_folder)}",
          "echo \"Zipping contents of '${abspath(local.temp_build_folder)}' to '${abspath(local.local_dependencies_zip_path)}'...\"",
          "zip -r ${abspath(local.local_dependencies_zip_path)} *",
        ]
      ]
    ))
  }
}

resource "aws_s3_bucket_object" "dependencies_layer_s3_zip" {
  count = 1 # count = local.local_requirements_file == null ? 0 : 1
  # count = var.upload_to_s3 ? 1 : 0
  # Parse the S3 path into 'bucket' and 'key' values:
  # https://gist.github.com/aaronsteers/19eb4d6cba926327f8b25089cb79259b
  bucket = split("/", split("//", var.s3_upload_path)[1])[0]
  key = replace(
    join("/", slice(
      split("/", split("//", var.s3_upload_path)[1]),
      1,
      length(split("/", split("//", var.s3_upload_path)[1]))
    ))
    , ".zip", "-${local.unique_suffix}.zip"
  )
  source     = local.local_dependencies_zip_path
  depends_on = [null_resource.create_dependency_zip[0]]

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_lambda_layer_version" "requirements_layer" {
#   count      = local.local_requirements_file == null ? 0 : 1
#   layer_name = "${var.name_prefix}dependencies-${local.unique_suffix}"
#   s3_bucket  = aws_s3_bucket_object.dependencies_layer_s3_zip[0].bucket
#   s3_key     = aws_s3_bucket_object.dependencies_layer_s3_zip[0].key
# }
