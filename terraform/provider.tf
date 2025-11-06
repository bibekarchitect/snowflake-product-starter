# Provider relies on environment variables only:
# SNOWFLAKE_ACCOUNT  -> UE47735
# SNOWFLAKE_REGION   -> europe-west4.gcp
# SNOWFLAKE_HOST     -> UE47735.europe-west4.gcp.snowflakecomputing.com
# SNOWFLAKE_USER, SNOWFLAKE_PASSWORD, SNOWFLAKE_ROLE
provider "snowflake" {}