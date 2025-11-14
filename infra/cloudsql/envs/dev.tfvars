project_id = "storied-box-478112-e8"
region     = "europe-west4"

network = "projects/storied-box-478112-e8/global/networks/vpc-data-platform"
subnet  = "projects/storied-box-478112-e8/regions/europe-west4/subnetworks/subnet-data-platform-ew4"
# ==== Cloud SQL naming ====
instance_name = "datahub-mysql"
db_name       = "datahub"
db_user       = "datahub_app"
db_pass       = "CHANGE_ME_STRONG_PASSWORD"

# ==== Service Networking private range (you can keep default) ====
allocated_ip_range = "google-managed-services-datahub"
