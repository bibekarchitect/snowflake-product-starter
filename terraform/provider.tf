# Auth/context come from env:
# SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER, SNOWFLAKE_PASSWORD, SNOWFLAKE_ROLE
# (and optionally SNOWFLAKE_REGION if you use locator instead of ORG-ACCOUNT)
provider "snowflake" {}