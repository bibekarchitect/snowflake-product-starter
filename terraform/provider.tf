# Provider takes explicit variables (set by publish.yml via -var)
provider "snowflake" {
  account   = var.snowflake_account     # e.g., UE47735
  region    = var.snowflake_region      # e.g., europe-west4.gcp
  username  = var.snowflake_user
  password  = var.snowflake_password
  role      = var.snowflake_role
}