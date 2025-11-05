terraform {
  required_version = ">= 1.6.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake" # official provider namespace
      version = "~> 2.9"                # pin to a stable 2.x series
    }
  }
}
