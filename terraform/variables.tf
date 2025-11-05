terraform {
  required_version = ">= 1.6.0"
}

# ---- Provider auth & account naming (new provider schema) ----
variable "snowflake_org_name"     { type = string } # e.g., "XYAUPKY"
variable "snowflake_account_name" { type = string } # e.g., "XH85556"
variable "snowflake_user"         { type = string } # e.g., "CICD_BOT"
variable "snowflake_password"     { type = string } # secret in CI
variable "snowflake_role"         { type = string } # e.g., "CICD_SNOWFLAKE_DEPLOY"

# ---- Module/runtime config for your product ----
variable "create_database" {
  type    = bool
  default = false
}

variable "database_name" {
  type    = string
  default = "CUSTOMER360_DEV"
}

variable "warehouses" {
  type = object({
    ingest    = string
    transform = string
    serve     = string
  })
}

variable "resource_monitor" {
  type = object({
    name                = string
    monthly_credits_cap = number
    notify_at           = list(number)
  })
}