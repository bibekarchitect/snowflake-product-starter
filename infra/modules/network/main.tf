resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.ip_range_pods
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.ip_range_svc
  }

  private_ip_google_access = true
}

output "network_id"       { value = google_compute_network.vpc.id }
output "network_self_link"{ value = google_compute_network.vpc.self_link }
output "subnet_name"      { value = google_compute_subnetwork.subnet.name }
output "subnet_self_link" { value = google_compute_subnetwork.subnet.self_link }