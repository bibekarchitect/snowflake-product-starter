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
  wh_names = {
    ingest    = snowflake_warehouse.ingest.name
    transform = snowflake_warehouse.transform.name
    serve     = snowflake_warehouse.serve.name
  }
}

resource "null_resource" "attach_rm" {
  for_each = var.resource_monitor_name == "" ? {} : local.wh_names

  triggers = {
    wh_name = each.value
    rm_name = var.resource_monitor_name
  }

  provisioner "local-exec" {
  interpreter = ["bash", "-lc"]
  command = <<EOT
python3 -m pip install --quiet --disable-pip-version-check snowflake-connector-python

cat <<'PY' > /tmp/attach_rm.py
import os
import snowflake.connector as sf

acct  = os.environ["SNOW_ACCOUNT"]
user  = os.environ["SNOW_USER"]
pwd   = os.environ["SNOW_PWD"]
role  = os.environ.get("SNOW_ROLE", "ACCOUNTADMIN")

wh    = os.environ["WH_NAME"]
rm    = os.environ["RM_NAME"]

conn = sf.connect(account=acct, user=user, password=pwd, role=role)
try:
    with conn.cursor() as cs:
        cs.execute(f"ALTER WAREHOUSE IDENTIFIER('{wh}') SET RESOURCE_MONITOR = IDENTIFIER('{rm}')")
        print(f"Attached {rm} to {wh}")
finally:
    conn.close()
PY

python3 /tmp/attach_rm.py
EOT

  environment = {
    WH_NAME      = each.value
    RM_NAME      = var.resource_monitor_name

    SNOW_ACCOUNT = "xyaupky-xh85556.europe-west4.gcp"
    SNOW_USER    = var.svc_admin_user
    SNOW_PWD     = var.svc_admin_password
    SNOW_ROLE    = "ACCOUNTADMIN"
  }
}

  depends_on = [
    snowflake_warehouse.ingest,
    snowflake_warehouse.transform,
    snowflake_warehouse.serve
  ]
}