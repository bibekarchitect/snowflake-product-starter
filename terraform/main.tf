resource "snowflake_database" "db" {
  count = var.create_database ? 1 : 0
  name  = var.database_name
}

resource "snowflake_warehouse" "ingest" {
  name             = var.warehouses.ingest
  warehouse_size   = "XSMALL"
  auto_suspend     = 60
  auto_resume      = true
  #resource_monitor = length(var.resource_monitor_name) > 0 ? var.resource_monitor_name : null
}

resource "snowflake_warehouse" "transform" {
  name             = var.warehouses.transform
  warehouse_size   = "SMALL"
  auto_suspend     = 60
  auto_resume      = true
  #resource_monitor = length(var.resource_monitor_name) > 0 ? var.resource_monitor_name : null
}

resource "snowflake_warehouse" "serve" {
  name             = var.warehouses.serve
  warehouse_size   = "XSMALL"
  auto_suspend     = 60
  auto_resume      = true
  #resource_monitor = length(var.resource_monitor_name) > 0 ? var.resource_monitor_name : null
}

# resource "snowflake_warehouse" "ingest1" {
#   name             = "TEST_TF_WH"
#   warehouse_size   = "XSMALL"
#   auto_suspend     = 60
#   auto_resume      = true
#   #resource_monitor = length(var.resource_monitor_name) > 0 ? var.resource_monitor_name : null
# }