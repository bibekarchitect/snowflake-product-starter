# ---------------------
# Project / Region
# ---------------------
project_id = "storied-box-478112-e8"
env        = "dev"
region     = "europe-west4"
zone       = "europe-west4-a"

# ---------------------
# VPC & Subnet
# ---------------------
network_name  = "dev-datahub-vpc"
subnet_name   = "dev-datahub-subnet"
subnet_cidr   = "10.38.0.0/20"

ip_range_pods = "10.40.0.0/16"
ip_range_svc  = "10.41.0.0/20"

# ---------------------
# GKE Cluster
# ---------------------
gke_cluster_name  = "dev-datahub-gke"
gke_machine_type = "e2-standard-4"
gke_min_nodes     = 0  # commented out because this variable is not defined/expected by the module
gke_max_nodes     = 1  # removed because the module does not accept this attribute; configure node-pool autoscaling using the module's expected variables (e.g., node_pool_autoscaling or max_node_count)
deletion_protection = false

# ---------------------
# Cloud SQL (MySQL)
# ---------------------
allocated_ip_range = "dev-sql-iprange"
instance_name      = "dev-datahub-sql"
tier               = "db-custom-1-3840"

db_name = "datahub"
db_user = "datahub_app"
# db_pass = "some-dev-password"