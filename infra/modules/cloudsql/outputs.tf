output "instance_connection_name" {
  value = google_sql_database_instance.mysql.connection_name
}

output "instance_ip_address" {
  # private IP only
  value = google_sql_database_instance.mysql.private_ip_address
}