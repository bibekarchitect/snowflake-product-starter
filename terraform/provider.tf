terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = ">= 0.96.0"
    }
  }
  required_version = ">= 1.6.0"
}

# Provider reads auth & context from environment variables:
#   SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD, SNOWFLAKE_ROLE, SNOWFLAKE_REGION
provider "snowflake" {}