
locals {
  required_apis = toset([
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "artifactregistry.googleapis.com",
    "storage.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
  ])

  automation_roles = toset([
    "roles/editor",
    "roles/compute.admin",
    "roles/container.admin",
    "roles/servicenetworking.networksAdmin",
    "roles/cloudsql.admin",
    "roles/artifactregistry.admin",
    "roles/storage.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/logging.admin",
    "roles/monitoring.admin",
  ])
}

resource "google_project_service" "required" {
  for_each = local.required_apis
  project  = var.project_id
  service  = each.key
  disable_on_destroy = false
}

resource "google_service_account" "automation" {
  account_id   = var.automation_sa_name
  display_name = var.automation_sa_display_name
  project      = var.project_id
}

resource "google_project_iam_member" "automation_roles" {
  for_each = local.automation_roles
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.automation.email}"
}

resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.wif_pool_id
  display_name              = var.wif_pool_display_name
  description               = "OIDC pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id
  display_name                       = var.wif_provider_display_name

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.actor"      = "assertion.actor"
  }

  attribute_condition = "assertion.repository=='${var.github_repo}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "wif_impersonation" {
  service_account_id = google_service_account.automation.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_repo}"
}

