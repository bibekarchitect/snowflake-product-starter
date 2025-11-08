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

# Attach the monitor via snowsql (ACCOUNTADMIN or equivalent)
locals {
  # map of the actual names from the resources just created
  wh_names = {
    ingest   = snowflake_warehouse.ingest.name
    transform= snowflake_warehouse.transform.name
    serve    = snowflake_warehouse.serve.name
  }
}

resource "null_resource" "attach_rm" {
  # only when a monitor name is provided
  for_each = var.resource_monitor_name == "" ? {} : local.wh_names

  # make changes re-run if either name or RM changes
  triggers = {
    wh_name = each.value
    rm_name = var.resource_monitor_name
  }

  provisioner "local-exec" {
    command = "snowsql -o exit_on_error=true -q \"ALTER WAREHOUSE IDENTIFIER('${each.value}') SET RESOURCE_MONITOR = IDENTIFIER('${var.resource_monitor_name}');\""
    environment = {
      SNOWSQL_ACCOUNT   = var.snowflake_account
      SNOWSQL_USER      = var.svc_admin_user         # use a service admin user, NOT your personal ID
      SNOWSQL_PWD       = var.svc_admin_password
      SNOWSQL_ROLE      = "ACCOUNTADMIN"
      # optionally:
      # SNOWSQL_REGION  = var.snowflake_region
      # SNOWSQL_WAREHOUSE = var.admin_wh
      # SNOWSQL_DATABASE  = var.admin_db
      # SNOWSQL_SCHEMA    = var.admin_schema
    }
  }

  # ensure warehouses exist first
  depends_on = [
    snowflake_warehouse.ingest,
    snowflake_warehouse.transform,
    snowflake_warehouse.serve
  ]
}