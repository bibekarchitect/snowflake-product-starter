terraform {
}

locals {
  enabled_services = toset([
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicenetworking.googleapis.com",
    "dns.googleapis.com",
    "sqladmin.googleapis.com"
  ])
}

resource "google_project_service" "this" {
  for_each = local.enabled_services
  service = each.key
  disable_on_destroy = false
}

output "services" {
  value = google_project_service.this
}
