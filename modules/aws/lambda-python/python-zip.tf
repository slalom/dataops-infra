data "http" "additional_reqs" {
  for_each = var.additional_tool_urls
  url      = each.value
}

resource "local_file" "additional_reqs_local" {
  for_each = var.additional_tool_urls
  filename = "${path.module}/../../${each.key}"
  content  = data.http.additional_reqs[each.value].content
}

resource "null_resource" "pip" {
  # Prepares Lambda package (https://github.com/hashicorp/terraform/issues/8344#issuecomment-345807204)
  triggers = {
    requirements = "${base64sha256(file("${var.source_root}/requirements.txt"))}"
  }
  provisioner "local-exec" {
    command = "${var.pip_path} install -r ${var.source_root}/requirements.txt -t ${var.build_root}"
  }
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${var.build_root}/"
  output_path = "${var.build_root}/../${var.function_name}.zip"
  depends_on  = [null_resource.pip, local_file.additional_reqs_local]
}
