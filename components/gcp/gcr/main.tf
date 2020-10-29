/*
* GCR (Google Container Registry) is the private-hosted GCP equivalent of DockerHub. GCR allows you to securely publish docker images which
* should not be accessible to external users.
*
*/


resource "google_container_registry" "gcr_repo" {
  project  = "my-project"
  location = "EU"
}



//resource "aws_ecr_repository" "ecr_repo" {
//  name = "${replace(lower(var.repository_name), "_", "-")}/${lower(var.image_name)}"
//  tags = var.resource_tags
//  # lifecycle { prevent_destroy = true }
//}
