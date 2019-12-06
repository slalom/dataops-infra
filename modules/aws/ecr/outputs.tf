output "ecr_repo_arn" { value = "${aws_ecr_repository.ecr_repo.arn}" }
output "ecr_repo_root" { value = "${dirname(aws_ecr_repository.ecr_repo.repository_url)}" }
output "ecr_image_url" { value = "${aws_ecr_repository.ecr_repo.repository_url}" }
