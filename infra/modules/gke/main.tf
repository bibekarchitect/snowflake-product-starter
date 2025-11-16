resource "google_container_cluster" "gke" {
  name = var.gke_name
  location = var.location
  network = var.network_id
  subnetwork = var.subnet_name
  remove_default_node_pool = true
  initial_node_count = 1
  deletion_protection = var.deletion_protection
  
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "default_pool" {
  name = "node-pool-default"
  location = var.location
  cluster = google_container_cluster.gke.name

  node_config {
    machine_type = var.gke_machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
    mode = "GKE_METADATA"
  }
  }

  autoscaling {
    min_node_count = var.gke_min_nodes
    max_node_count = var.gke_max_nodes
  }
}