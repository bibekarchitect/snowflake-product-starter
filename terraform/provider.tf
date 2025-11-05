# Use explicit variables instead of env autodiscovery.
# For org-scoped accounts like XYAUPKY-XH85556, do NOT set region.
provider "snowflake" {
  account_identifier = var.snowflake_account
  user               = var.snowflake_user
  password           = var.snowflake_password
  role               = var.snowflake_role
}
