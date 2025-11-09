resource "google_project_service" "apis" {
  for_each = toset(["compute.googleapis.com","dns.googleapis.com","servicenetworking.googleapis.com"])
  project = var.project_id
  service = each.key
}

resource "google_compute_address" "psc_ip" {
  name         = "psc-snowflake-ip"
  region       = var.region
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  subnetwork   = var.subnet
}

resource "google_compute_forwarding_rule" "psc_endpoint" {
  name                  = "psc-snowflake-endpoint"
  region                = var.region
  network               = var.network
  subnetwork            = var.subnet
  load_balancing_scheme = "INTERNAL"
  ip_address            = google_compute_address.psc_ip.self_link
  target                = var.snowflake_service_attachment
}

resource "google_dns_managed_zone" "private_zone" {
  project    = var.project_id
  name       = var.dns_zone_name
  dns_name   = "${var.dns_zone_domain}."
  visibility = "private"
  private_visibility_config {
    networks { network_url = var.network }
  }
}

resource "google_dns_record_set" "account_a_record" {
  project      = var.project_id
  managed_zone = google_dns_managed_zone.private_zone.name
  name         = "${var.snowflake_account_hostname}."
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_address.psc_ip.address]
}