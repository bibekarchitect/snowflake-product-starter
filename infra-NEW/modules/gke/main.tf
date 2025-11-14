resource "google_container_cluster" "gke" {
  name = var.gke_name
  location = var.location
  network = var.network_id
  subnetwork = var.subnet_name
  remove_default_node_pool = true
  initial_node_count = 1
}

resource "google_container_node_pool" "default_pool" {
  name = "np-default"
  location = var.location
  cluster = google_container_cluster.gke.name

  node_config {
    machine_type = var.gke_machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  autoscaling {
    min_node_count = var.gke_min_nodes
    max_node_count = var.gke_max_nodes
  }
}

output "cluster_name" { value = google_container_cluster.gke.name }
output "cluster_location" { value = google_container_cluster.gke.location }
output "cluster_ca_certificate" { value = "" }
