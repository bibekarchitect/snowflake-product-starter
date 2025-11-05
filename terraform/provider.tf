# For org-scoped accounts like XYAUPKY-XH85556.snowflakecomputing.com:
#   organization_name = "XYAUPKY"
#   account_name      = "XH85556"
#
# Credentials are passed via TF variables from the workflow (-var ...).
provider "snowflake" {
  organization_name = var.snowflake_org_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_user
  password          = var.snowflake_password
  role              = var.snowflake_role
}
