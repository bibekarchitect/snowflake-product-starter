# module "project_services" {
#   source = "../../modules/project_services"
# }

module "network" {
  source = "../../modules/network"
  network_name = var.network_name
  subnet_name  = var.subnet_name
  subnet_cidr  = var.subnet_cidr
  region       = var.region
  ip_range_pods = var.ip_range_pods
  ip_range_svc  = var.ip_range_svc
}

module "gke" {
  source = "../../modules/gke"
  gke_name = var.gke_name
  location = var.location
  network_id = module.network.network_id
  subnet_name = module.network.subnet_name
  gke_machine_type = var.gke_machine_type
  gke_min_nodes = var.gke_min_nodes
  gke_max_nodes = var.gke_max_nodes
}

module "cloudsql" {
  source = "../../modules/cloudsql"
  network_self_link = module.network.network_self_link
  allocated_ip_range = var.allocated_ip_range
  instance_name = var.sql_instance_name
  region = var.region
  tier = var.sql_tier
  db_name = var.sql_db_name
  db_user = var.sql_db_user
  db_pass = var.sql_db_pass
}

# module "iam_prereqs" {
#   source = "../../modules/iam"

#   project_id                  = var.project_id
#   automation_sa_name          = "datahub-automation-sa"
#   automation_sa_display_name  = "DataHub Automation SA (Terraform + GitHub Actions)"
#   github_repo                 = "bibekarchitect/snowflake-product-starter"
#   wif_pool_id                 = "github-pool"
#   wif_pool_display_name       = "GitHub Actions Workload Identity Pool"
#   wif_provider_id             = "github-provider"
#   wif_provider_display_name   = "GitHub Actions OIDC Provider"
# }
