resource "snowflake_resource_monitor" "rm" {
  name = var.resource_monitor.name
  credit_quota = var.resource_monitor.monthly_credits_cap
  notify_triggers = var.resource_monitor.notify_at
}

resource "snowflake_warehouse" "ingest" {
  name                 = var.warehouses.ingest
  warehouse_size       = "XSMALL"
  auto_suspend         = 120
  auto_resume          = true
  initially_suspended  = true
  resource_monitor     = snowflake_resource_monitor.rm.name
}

resource "snowflake_warehouse" "transform" {
  name                 = var.warehouses.transform
  warehouse_size       = "SMALL"
  auto_suspend         = 120
  auto_resume          = true
  initially_suspended  = true
  resource_monitor     = snowflake_resource_monitor.rm.name
}

resource "snowflake_warehouse" "serve" {
  name                 = var.warehouses.serve
  warehouse_size       = "XSMALL"
  auto_suspend         = 60
  auto_resume          = true
  initially_suspended  = true
  resource_monitor     = snowflake_resource_monitor.rm.name
}

resource "snowflake_database" "db" {
  count = var.create_database ? 1 : 0
  name  = var.database_name
}
