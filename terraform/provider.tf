# Official Snowflake provider (v2+)
# organization_name/account_name come from your org-scoped URL.
provider "snowflake" {
  organization_name = var.snowflake_org_name
  account_name      = var.snowflake_account_name
  user              = var.snowflake_user
  password          = var.snowflake_password
  role              = var.snowflake_role

  # If using key-pair auth instead of password, switch to:
  # authenticator          = "SNOWFLAKE_JWT"
  # private_key_path       = var.private_key_path
  # private_key_passphrase = var.private_key_passphrase
}
