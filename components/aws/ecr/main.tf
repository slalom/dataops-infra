/*
* ECR (Elastic Compute Repository) is the private-hosted AWS equivalent of DockerHub. ECR allows you to securely publish docker images which
* should not be accessible to external users.
*
*/

resource "aws_ecr_repository" "ecr_repo" {
  name = "${replace(lower(var.repository_name), "_", "-")}/${lower(var.image_name)}"
  tags = var.resource_tags
  # lifecycle { prevent_destroy = true }
}
