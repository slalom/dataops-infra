output "gcr_repo_id" {
  description = "The unique ID (ARN) of the ECR repo."
  value       = "${google_container_registry.gcr_repo.id}"
}
//output "gcr_repo_root" {
//  description = "The path to the ECR repo, excluding image name."
//  value       = "${dirname(aws_ecr_repository.ecr_repo.repository_url)}"
//}
output "gcr_image_url" {
  description = "The full path to the ECR image, including image name."
  value       = "${google_container_registry.gcr_repo.location}"
}
