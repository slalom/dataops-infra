output "ecr_repo_arn" {
  description = "The unique ID (ARN) of the ECR repo."
  value       = aws_ecr_repository.ecr_repo.arn
}
output "ecr_repo_root" {
  description = "The path to the ECR repo, excluding image name."
  value       = dirname(aws_ecr_repository.ecr_repo.repository_url)
}
output "ecr_image_url" {
  description = "The full path to the ECR image, including image name."
  value       = aws_ecr_repository.ecr_repo.repository_url
}
