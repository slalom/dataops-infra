# Step 1: Copy Files to temp directory

# resource "local_file" "canary_file" {
#   content  = local.temp_build_folder
#   filename = "${local.temp_build_folder}/foo.bar"
# }

# Step 2: Run `pip install` from within temp directory

resource "null_resource" "pip" {
  # Prepares Lambda package (https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204)
  triggers = {
    version_increment = 1.6 # used to force a refresh
    source_files_hash = local.source_files_hash
  }
  provisioner "local-exec" {
    command = join(local.is_windows ? "; " : " && ", flatten(
      [
        [
          # Copy files to temp directory
          local.is_windows ?
          [
            "New-Item -ItemType Directory -Force -Path ${local.temp_build_folder}",
            "copy ${var.lambda_source_folder}/* ${local.temp_build_folder}/",
          ] :
          [
            "mkdir -p ${local.temp_build_folder}",
            "cp ${var.lambda_source_folder}/* ${local.temp_build_folder}/",
          ]
        ],
        # Run `pip install` to compile dependencies
        "${local.pip_path} install --upgrade -r ${local.temp_build_folder}/requirements.txt --target ${local.temp_build_folder}"
      ]
    ))
    interpreter = local.is_windows ? ["Powershell", "-Command"] : ["/bin/bash", "-c"]
  }
  # depends_on = [local_file.canary_file, local_file.canary_file]
}

# # Step 3: Wait for things to finish

data "null_data_source" "wait_for_lambda_exporter" {
  # Workaround for explicit 'depends' issue within archive_file provider: https://github.com/terraform-providers/terraform-provider-archive/issues/11
  inputs = {
    # This ensures that this data resource will not be evaluated until
    # after the null_resource has been created.
    lambda_exporter_id = fileexists("${var.lambda_source_folder}/requirements.txt") ? null_resource.pip.id : null
    copy_files_id      = null_resource.pip.id

    # This value gives us something to implicitly depend on
    # in the archive_file below.
    source_dir = "${local.temp_build_folder}/"
  }
  depends_on = [null_resource.pip]
}

# Step 4: Create a packaged zip of the temp directory

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = data.null_data_source.wait_for_lambda_exporter.outputs["source_dir"]
  output_path = replace(local.zip_local_path, ".zip", "-${null_resource.pip.id}.zip")
  depends_on = [
    # local_file.canary_file,
    null_resource.pip,
    data.null_data_source.wait_for_lambda_exporter,
  ]
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
  # etag   = filebase64sha256(data.archive_file.lambda_zip.output_path)
}
