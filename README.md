# Snowflake Data Product — Single Manifest (GitHub Actions, Fixed)

This version passes Terraform variables from **GitHub Environment Secrets** directly (no tfvars placeholders),
and the sample model no longer references a non-existent `CURATED.CUSTOMERS` table.

## Quick Start
1) Create GitHub Environments: `dev`, `uat`, `prod`.
2) Add Environment Secrets: `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, `SNOWFLAKE_PASSWORD`, `SNOWFLAKE_ROLE`, `SNOWFLAKE_REGION`.
   Optional: `DATAHUB_GMS_HOST`, `DATAHUB_GMS_TOKEN`.
3) Push to GitHub.
4) Actions → **Publish Data Product** → Run:
   - environment = dev
   - apply = true (to create warehouses + render SQL)
   - execute_sql = true (if allowed) to run SQL
   - catalog = false/true (optional)

### Optional DB Creation
The workflow exposes an input `create_database` (default false). When true, Terraform will create `layout.database`
from `product.yml`. Ensure your CI role has `CREATE DATABASE` privilege.
