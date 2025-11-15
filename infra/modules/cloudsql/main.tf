resource "google_compute_global_address" "private_ip_alloc" {
  name          = var.allocated_ip_range
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = var.network_self_link
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

resource "google_sql_database_instance" "mysql" {
  name             = var.instance_name
  project          = var.project_id
  region           = var.region
  database_version = "MYSQL_8_0"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = var.tier

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_self_link
    }
  }
}

resource "google_sql_database" "datahub" {
  name     = var.db_name
  instance = google_sql_database_instance.mysql.name
}

resource "google_sql_user" "app" {
  name     = var.db_user
  instance = google_sql_database_instance.mysql.name
  password = var.db_pass
}

output "instance_connection_name" {
  value = google_sql_database_instance.mysql.connection_name
}