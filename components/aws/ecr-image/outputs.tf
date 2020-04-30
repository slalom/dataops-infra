output "ecr_repo_arn" {
  description = "The unique ID (ARN) of the ECR repo."
  value       = var.is_disabled ? null : "${aws_ecr_repository.ecr_repo[0].arn}"
}
output "ecr_repo_root" {
  description = "The path to the ECR repo, excluding image name."
  value       = var.is_disabled ? null : "${dirname(aws_ecr_repository.ecr_repo[0].repository_url)}"
}
output "ecr_image_url" {
  description = "The full path to the ECR image, including image name."
  value       = var.is_disabled ? null : "${aws_ecr_repository.ecr_repo[0].repository_url}"
}
output "ecr_image_url_and_tag" {
  description = "The full path to the ECR image, including image name and tag."
  value       = var.is_disabled ? null : "${aws_ecr_repository.ecr_repo[0].repository_url}:${var.tag}"
}
