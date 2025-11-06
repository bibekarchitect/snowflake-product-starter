# Provider reads credentials/context from environment variables:
#   SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD, SNOWFLAKE_ROLE
#   Optionally SNOWFLAKE_REGION (needed only if using account locator).
provider "snowflake" {}