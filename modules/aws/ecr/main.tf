resource "aws_ecr_repository" "ecr_repo" {
  name = "${replace(lower(var.repository_name), "_", "-")}/${lower(var.image_name)}"
  tags = { project = var.project_shortname }
  # lifecycle { prevent_destroy = true }
}
