# NOTE: We are NOT creating a resource monitor in TF anymore.
# We only reference a pre-existing one by name in each warehouse.

# Optional database creation (toggle via -var create_database=true)
resource "snowflake_database" "db" {
  count = var.create_database ? 1 : 0
  name  = var.database_name
}

# Warehouses — attach to existing resource monitor by name, or none if ""
resource "snowflake_warehouse" "ingest" {
  name                 = var.warehouses.ingest
  warehouse_size       = "XSMALL"
  auto_suspend         = 120
  auto_resume          = true
  initially_suspended  = true
  resource_monitor     = length(var.resource_monitor_name) > 0 ? var.resource_monitor_name : null
}

resource "snowflake_warehouse" "transform" {
  name                 = var.warehouses.transform
  warehouse_size       = "SMALL"
  auto_suspend         = 120
  auto_resume          = true
  initially_suspended  = true
  resource_monitor     = length(var.resource_monitor_name) > 0 ? var.resource_monitor_name : null
}

resource "snowflake_warehouse" "serve" {
  name                 = var.warehouses.serve
  warehouse_size       = "XSMALL"
  auto_suspend         = 60
  auto_resume          = true
  initially_suspended  = true
  resource_monitor     = length(var.resource_monitor_name) > 0 ? var.resource_monitor_name : null
}