# The Snowflake provider reads credentials from environment variables:
#   SNOWFLAKE_ACCOUNT
#   SNOWFLAKE_USER
#   SNOWFLAKE_PASSWORD
#   SNOWFLAKE_ROLE
#   SNOWFLAKE_REGION (optional for org-scoped accounts)
provider "snowflake" {}
