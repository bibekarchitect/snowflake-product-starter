project_id = "crested-trilogy-474807-p5"
region     = "europe-west4"

# Self links (recommended)
network = "projects/crested-trilogy-474807-p5/global/networks/vpc-data-platform"
subnet  = "projects/crested-trilogy-474807-p5/regions/europe-west4/subnetworks/subnet-data-platform-ew4"

# Snowflake
snowflake_account_hostname   = "ue47735.europe-west4.privatelink.snowflakecomputing.com"
snowflake_service_attachment = "projects/europe-west4-deployment1-f832/regions/europe-west4/serviceAttachments/snowflake-europe-west4-psc"

# DNS (keep defaults unless you need custom)
dns_zone_domain = "snowflakecomputing.com"
dns_zone_name   = "snowflake-private-zone"