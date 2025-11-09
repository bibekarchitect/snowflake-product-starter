output "psc_ip" { value = google_compute_address.psc_ip.address }
output "dns_zone" { value = google_dns_managed_zone.private_zone.name }
output "forwarding_rule" { value = google_compute_forwarding_rule.psc_endpoint.name }