provider "snowflake" {
  # Pass these via -var from your workflow
  account_name  = var.snowflake_account      # e.g., UE47735
  #region   = var.snowflake_region       # e.g., europe-west4.gcp
  user     = var.snowflake_user         # e.g., CICD_BOT
  password = var.snowflake_password
  role     = var.snowflake_role         # e.g., CICD_SNOWFLAKE_DEPLOY
}