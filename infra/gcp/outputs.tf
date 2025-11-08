output "network"        { value = google_compute_network.vpc.name }
output "subnet"         { value = google_compute_subnetwork.subnet.name }
output "cluster_name"   { value = google_container_cluster.gke.name }
output "location"       { value = google_container_cluster.gke.location }
output "workload_pool"  { value = google_container_cluster.gke.workload_identity_config[0].workload_pool }
