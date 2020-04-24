/*
* ECR (Elastic Compute Repository) is the private-hosted AWS equivalent of DockerHub. 
* ECR allows you to securely publish docker images which should not be accessible to external users.
*/

locals {
  source_image_hash = join(",", [
    for filepath in fileset(var.source_image_path, "*") :
    filebase64sha256("${var.source_image_path}/${filepath}")
  ])
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}

resource "aws_ecr_repository" "ecr_repo" {
  count = var.is_disabled ? 0 : 1
  name  = "${var.name_prefix}${replace(lower(var.repository_name), "_", "-")}"
  tags  = var.resource_tags
  # lifecycle { prevent_destroy = true }
}

resource "null_resource" "push" {
  count    = var.is_disabled ? 0 : 1
  triggers = {
    source_files_hash = local.source_image_hash
  }

  provisioner "local-exec" {
    command     = <<EOT
      docker build -t ${aws_ecr_repository.ecr_repo[0].name} ${var.source_image_path}
      $((Get-ECRLoginCommand).Password | docker login --username AWS --password-stdin ${aws_ecr_repository.ecr_repo[0].repository_url})
      docker tag ${aws_ecr_repository.ecr_repo[0].name}:${var.tag} ${aws_ecr_repository.ecr_repo[0].repository_url}:${var.tag}
      docker push ${aws_ecr_repository.ecr_repo[0].repository_url}:${var.tag}
EOT
    interpreter = ["powershell"]
  }
}
