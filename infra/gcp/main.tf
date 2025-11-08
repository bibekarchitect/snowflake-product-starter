resource "google_project_service" "services" {
  for_each = toset([
    "container.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicenetworking.googleapis.com",
    "dns.googleapis.com"
  ])
  service = each.key
}

resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = "10.38.0.0/20"
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

resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config { enable = true, filter = "ERRORS_ONLY" }
}

locals {
  channel = var.gke_release_channel
  wi_pool = coalesce(var.workload_pool, "${var.project_id}.svc.id.goog")
}

resource "google_container_cluster" "gke" {
  provider           = google-beta
  name               = var.gke_name
  location           = var.location
  network            = google_compute_network.vpc.id
  subnetwork         = google_compute_subnetwork.subnet.name
  remove_default_node_pool = true
  initial_node_count = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  private_cluster_config {
    enable_private_nodes    = var.private_cluster
    enable_private_endpoint = false
    master_global_access_config { enabled = true }
  }

  dynamic "master_authorized_networks_config" {
    for_each = length(var.master_authorized_cidrs) > 0 ? [1] : []
    content {
      cidr_blocks = [
        for cidr in var.master_authorized_cidrs : { cidr_block = cidr, display_name = "allowed" }
      ]
    }
  }

  release_channel { channel = local.channel }

  workload_identity_config { workload_pool = local.wi_pool }

  enable_shielded_nodes = true

  depends_on = [google_project_service.services]
}

resource "google_container_node_pool" "default_pool" {
  provider  = google-beta
  name      = "np-default"
  location  = var.location
  cluster   = google_container_cluster.gke.name

  node_config {
    machine_type = var.gke_machine_type
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    workload_metadata_config { mode = "GKE_METADATA" }
    labels = { workload = "datahub" }
    metadata = { disable-legacy-endpoints = "true" }
    shielded_instance_config { enable_secure_boot = true }
  }

  autoscaling { min_node_count = var.gke_min_nodes, max_node_count = var.gke_max_nodes }
  management { auto_repair = true, auto_upgrade = true }

  depends_on = [google_container_cluster.gke]
}
