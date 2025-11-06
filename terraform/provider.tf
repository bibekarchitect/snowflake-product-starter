provider "snowflake" {
  account  = var.snowflake_account      # e.g., UE47735
  region   = var.snowflake_region       # e.g., europe-west4.gcp
  user     = var.snowflake_user         # CICD_BOT
  password = var.snowflake_password
  role     = var.snowflake_role         # CICD_SNOWFLAKE_DEPLOY
}