########################################
# Private Service Connect (PSC) to Snowflake
########################################

# Enable required APIs
resource "google_project_service" "apis" {
  for_each = toset([
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com"
  ])
  project = var.project_id
  service = each.key
}

# Reserve an internal IP for the PSC endpoint
resource "google_compute_address" "psc_ip" {
  name         = "psc-snowflake-ip"
  region       = var.region
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  subnetwork   = var.subnet

  depends_on = [google_project_service.apis]
}

# PSC consumer endpoint (forwarding rule)
resource "google_compute_forwarding_rule" "psc_endpoint" {
  provider   = google-beta
  name       = "psc-snowflake-endpoint"
  region     = var.region
  network    = var.network
  subnetwork = var.subnet

  # IMPORTANT:
  # 1) Use self_link (URL), not the raw IP string
  ip_address = google_compute_address.psc_ip.self_link

  # 2) Explicitly set empty scheme to prevent the provider from defaulting EXTERNAL
  load_balancing_scheme = ""  # <-- critical for PSC consumer

  # Snowflake-provided serviceAttachment URI (must match your region)
  target = var.snowflake_service_attachment

  # Optional, if you need cross-region consumption
  # allow_psc_global_access = true

  # Defensive: ignore fields some provider builds try to inject on PSC
  lifecycle {
    ignore_changes = [
      is_mirroring_collector,
      ip_protocol,
      ports,
      labels,                # avoid label diffs if your org injects defaults
      load_balancing_scheme, # extra guard even though we set ""
    ]
  }

  depends_on = [google_compute_address.psc_ip]
}

# Private DNS zone attached to the GKE VPC
resource "google_dns_managed_zone" "private_zone" {
  project    = var.project_id
  name       = var.dns_zone_name
  dns_name   = "${var.dns_zone_domain}."
  visibility = "private"

  private_visibility_config {
    networks { network_url = var.network }
  }

  depends_on = [google_project_service.apis]
}

# A record for your exact Snowflake account hostname -> PSC internal IP
resource "google_dns_record_set" "account_a_record" {
  project      = var.project_id
  managed_zone = google_dns_managed_zone.private_zone.name
  name         = "${var.snowflake_account_hostname}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.psc_ip.address]

  depends_on = [
    google_dns_managed_zone.private_zone,
    google_compute_forwarding_rule.psc_endpoint
  ]
}