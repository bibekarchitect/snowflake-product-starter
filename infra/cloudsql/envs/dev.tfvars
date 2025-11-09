project_id = "crested-trilogy-474807-p5"
region     = "europe-west4"

network = "projects/crested-trilogy-474807-p5/global/networks/vpc-data-platform"
subnet  = "projects/crested-trilogy-474807-p5/regions/europe-west4/subnetworks/subnet-data-platform-ew4"
# ==== Cloud SQL naming ====
instance_name = "datahub-mysql"
db_name       = "datahub"
db_user       = "datahub_app"
db_pass       = "CHANGE_ME_STRONG_PASSWORD"

# ==== Service Networking private range (you can keep default) ====
allocated_ip_range = "google-managed-services-datahub"
