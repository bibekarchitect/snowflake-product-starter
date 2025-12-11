resource "google_artifact_registry_repository" "docker_repo" {
  provider      = google
  project       = var.project_id
  location      = var.region
  format        = "DOCKER"
  repository_id = var.repository_name

  description = var.description
  labels      = var.labels
}

# OPTIONAL: Grant IAM permissions to a Service Account for pushing images
resource "google_artifact_registry_repository_iam_member" "push_pull" {
  for_each = var.service_accounts
  project  = var.project_id
  location = var.region
  repository = google_artifact_registry_repository.docker_repo.repository_id
  role     = "roles/artifactregistry.writer"
  member   = "serviceAccount:${each.value}"
}