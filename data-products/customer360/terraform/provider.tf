terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = ">= 1.0.0"
    }
  }
}

provider "snowflake" {
  organization_name = var.snowflake_org
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  password          = var.snowflake_password
  role              = var.snowflake_role
}

provider "snowflake" {
  alias   = "admin"
  role    = "ACCOUNTADMIN"
  organization_name = var.snowflake_org
  account_name      = var.snowflake_account
  user              = var.svc_admin_user
  password          = var.svc_admin_password
}

terraform {
      backend "gcs" {
        bucket = "tw-tf-state-prod"
        prefix = "terraform/state" # Optional: specify a path within the bucket
      }
    }