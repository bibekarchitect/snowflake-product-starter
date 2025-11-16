# 1) GCP Service Account used by GKE workloads
resource "google_service_account" "datahub_gke" {
  account_id   = "datahub-gke-sa"
  display_name = "DataHub GKE workloads"
}

# 2) IAM roles for Cloud SQL + IAM DB auth
resource "google_project_iam_member" "datahub_gke_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.datahub_gke.email}"
}

resource "google_project_iam_member" "datahub_gke_cloudsql_instance_user" {
  project = var.project_id
  role    = "roles/cloudsql.instanceUser"
  member  = "serviceAccount:${google_service_account.datahub_gke.email}"
}

# Optional for admin-like permissions in lab only (DO NOT use in prod)
# resource "google_project_iam_member" "datahub_gke_cloudsql_admin" {
#   project = var.project_id
#   role    = "roles/cloudsql.admin"
#   member  = "serviceAccount:${google_service_account.datahub_gke.email}"
# }

# 3) Bind K8s ServiceAccount -> GCP SA via Workload Identity
#
# This assumes your GKE cluster has:
# workload_identity_config {
#   workload_pool = "${var.project_id}.svc.id.goog"
# }
#
resource "google_service_account_iam_member" "datahub_gke_wi_binding" {
  service_account_id = google_service_account.datahub_gke.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.gke_namespace}/${var.gke_service_account_name}]"
}
