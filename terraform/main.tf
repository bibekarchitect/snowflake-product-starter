resource "snowflake_database" "db" {
  count = var.create_database ? 1 : 0
  name  = var.database_name
}

resource "snowflake_warehouse" "ingest" {
  name             = var.warehouses.ingest
  warehouse_size   = "XSMALL"
  auto_suspend     = 60
  auto_resume      = true
  # prevent drift if someone sets a monitor outside this role
  lifecycle { ignore_changes = [resource_monitor] }
}

resource "snowflake_warehouse" "transform" {
  name             = var.warehouses.transform
  warehouse_size   = "SMALL"
  auto_suspend     = 60
  auto_resume      = true
  # prevent drift if someone sets a monitor outside this role
  lifecycle { ignore_changes = [resource_monitor] }
}

resource "snowflake_warehouse" "serve" {
  name             = var.warehouses.serve
  warehouse_size   = "XSMALL"
  auto_suspend     = 60
  auto_resume      = true
  # prevent drift if someone sets a monitor outside this role
  lifecycle { ignore_changes = [resource_monitor] }
}

# resource "snowflake_warehouse" "ingest1" {
#   name             = "TEST_TF_WH"
#   warehouse_size   = "XSMALL"
#   auto_suspend     = 60
#   auto_resume      = true
#   #resource_monitor = length(var.resource_monitor_name) > 0 ? var.resource_monitor_name : null
# }

locals {
  wh_resources = {
    ingest    = snowflake_warehouse.ingest
    transform = snowflake_warehouse.transform
    serve     = snowflake_warehouse.serve
  }
}

resource "snowflake_sql" "attach_rm" {
  provider = snowflake.admin
  for_each = var.resource_monitor_name == "" ? {} : local.wh_resources
  sql      = "ALTER WAREHOUSE IDENTIFIER('${each.value.name}') SET RESOURCE_MONITOR = IDENTIFIER('${var.resource_monitor_name}');"
  depends_on = [each.value]
}