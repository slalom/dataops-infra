/*
* ECR (Elastic Compute Repository) is the private-hosted AWS
* equivalent of DockerHub. ECR allows you to securely publish
* docker images which should not be accessible to external users.
*
*/

locals {
  source_image_hash = join(",", [
    for filepath in fileset(var.source_image_path, "*") :
    filebase64sha256("${var.source_image_path}/${filepath}")
  ])
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
  build_args_str = join(" ", [
    for k, v in var.build_args :
    "--build-arg ${k}=${v}"
  ])
}

resource "aws_ecr_repository" "ecr_repo" {
  name = replace(lower("${var.name_prefix}${var.repository_name}"), "_", "-")
  tags = var.resource_tags
  # lifecycle { prevent_destroy = true }
}

resource "null_resource" "push" {
  triggers = {
    source_files_hash = local.source_image_hash
    build_args_str    = local.build_args_str
  }

  provisioner "local-exec" {
    command     = <<EOT
docker build ${local.build_args_str} -t ${aws_ecr_repository.ecr_repo.name} ${abspath(var.source_image_path)};
${local.is_windows ? "$env:" : "export "}AWS_SHARED_CREDENTIALS_FILE="${abspath(var.aws_credentials_file)}";
docker tag ${aws_ecr_repository.ecr_repo.name}:${var.tag} ${aws_ecr_repository.ecr_repo.repository_url}:${var.tag};
docker push ${aws_ecr_repository.ecr_repo.repository_url}:${var.tag};
EOT
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []

    # ${local.is_windows ? "Import-Module AWSPowerShell.NetCore; $((Get-ECRLoginCommand).Password | docker login --username AWS --password-stdin ${aws_ecr_repository.ecr_repo.repository_url})" : "aws ecr get-login-password --region ${var.environment.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.ecr_repo.repository_url}"};
  }
}
