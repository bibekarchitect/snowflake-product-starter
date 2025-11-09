
# ==== GCP project / region ====
project_id = "YOUR_GCP_PROJECT_ID"
region     = "europe-west4"

# ==== Networking (self links) ====
# VPC and Subnet used by your GKE cluster and Cloud SQL private IP
network = "https://www.googleapis.com/compute/v1/projects/YOUR_GCP_PROJECT_ID/global/networks/vpc-data-platform"
subnet  = "https://www.googleapis.com/compute/v1/projects/YOUR_GCP_PROJECT_ID/regions/europe-west4/subnetworks/subnet-data-platform-ew4"

# ==== Cloud SQL naming ====
instance_name = "datahub-mysql"
db_name       = "datahub"
db_user       = "datahub_app"
db_pass       = "CHANGE_ME_STRONG_PASSWORD"

# ==== Service Networking private range (you can keep default) ====
allocated_ip_range = "google-managed-services-datahub"
