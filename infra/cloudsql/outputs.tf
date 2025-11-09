
output "instance_connection_name" {
  value = google_sql_database_instance.mysql.connection_name
}
output "private_ip_address" {
  value = google_sql_database_instance.mysql.private_ip_address
}
output "db_name" {
  value = google_sql_database.datahub.name
}
output "db_user" {
  value = google_sql_user.app.name
}
