terraform {
  required_version = ">= 1.6.0"
}

# ---- Provider auth & account naming (official provider schema) ----
variable "snowflake_org_name"     { type = string } # e.g., "XYAUPKY"
variable "snowflake_account_name" { type = string } # e.g., "XH85556"
variable "snowflake_user"         { type = string } # e.g., "CICD_BOT"
variable "snowflake_password"     { type = string } # if using password auth (SnowSQL, etc.)
variable "snowflake_role"         { type = string } # e.g., "CICD_SNOWFLAKE_DEPLOY"

# If you switched Terraform to key-pair auth, also include:
# variable "private_key_path"       { type = string }
# variable "private_key_passphrase" { type = string }

# ---- Product config ----
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

# ✅ NEW: reference an existing monitor by name (not created by TF)
variable "resource_monitor_name" {
  type    = string
  default = "RM_CUSTOMER360" # set "" to attach none
}

variable "resource_monitor" {
  # kept for backward compatibility if your workflow still passes this object;
  # not used anymore to create a monitor, but you can keep it for documentation.
  type = object({
    name                = string
    monthly_credits_cap = number
    notify_at           = list(number)
  })
}