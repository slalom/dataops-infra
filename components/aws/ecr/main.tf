resource "aws_ecr_repository" "ecr_repo" {
  name = "${replace(lower(var.repository_name), "_", "-")}/${lower(var.image_name)}"
  tags = var.resource_tags
  # lifecycle { prevent_destroy = true }
}
