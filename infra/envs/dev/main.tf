# 1) Network
module "network" {
  source = "../../modules/network"
  project_id    = var.project_id
  env           = var.env
  region        = var.region
  network_name  = var.network_name
  subnet_name   = var.subnet_name
  subnet_cidr   = var.subnet_cidr
  ip_range_pods = var.ip_range_pods
  ip_range_svc  = var.ip_range_svc
}

# 2) Cloud SQL (private IP)
module "cloudsql" {
  source = "../../modules/cloudsql"

  project_id        = var.project_id
  region            = var.region
  env               = var.env

  network_self_link = module.network.network_self_link

  allocated_ip_range = var.allocated_ip_range
  instance_name      = var.instance_name
  tier               = var.tier

  db_name = var.db_name
  db_user = var.db_user
  db_pass = var.db_pass

  enable_iam_auth = true
}

# 3) GKE Cluster
module "gke" {
  source = "../../modules/gke"

  # Provide the attributes expected by the gke module
  location    = var.zone
  gke_name    = var.gke_cluster_name
  network_id  = module.network.network_self_link
  subnet_name = module.network.subnet_self_link
  gke_machine_type = var.gke_machine_type
  gke_min_nodes   = var.gke_min_nodes
  gke_max_nodes   = var.gke_max_nodes
  deletion_protection = var.deletion_protection
  project_id = var.project_id
}

module "iam" {
  source = "../../modules/iam"

  project_id               = var.project_id
  gke_namespace            = "datahub"
  gke_service_account_name = "datahub-gms"
}