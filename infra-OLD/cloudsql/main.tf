
resource "google_project_service" "sqladmin" {
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "servicenetworking" {
  service = "servicenetworking.googleapis.com"
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = var.allocated_ip_range
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = var.network
}

resource "google_service_networking_connection" "vpc_connection" {
  network                 = var.network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
  depends_on = [google_project_service.servicenetworking]
}

resource "google_sql_database_instance" "mysql" {
  name             = var.instance_name
  region           = var.region
  database_version = "MYSQL_8_0"

  settings {
    tier = "db-custom-1-3840" # small; adjust as needed
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network
    }
    availability_type = "ZONAL" # use REGIONAL for HA
    backup_configuration { enabled = true }
  }

  deletion_protection = false
  depends_on = [google_service_networking_connection.vpc_connection]
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
