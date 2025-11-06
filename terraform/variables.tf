terraform {
  required_version = ">= 1.6.0"
}

# ---- Provider auth & account naming (official provider schema) ----
variable "snowflake_org_name"     { type = string }  # e.g., "XYAUPKY"
variable "snowflake_account_name" { type = string }  # e.g., "XH85556"
variable "snowflake_user"         { type = string }  # e.g., "CICD_BOT"
variable "snowflake_password" {
  type      = string
  sensitive = true
}

variable "snowflake_role"         { type = string }  # e.g., "CICD_SNOWFLAKE_DEPLOY"

# If you switch to key-pair auth later, add:
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

  validation {
    condition     = length(trim(var.database_name)) > 0
    error_message = "database_name must be non-empty."
  }
}

variable "warehouses" {
  type = object({
    ingest    = string
    transform = string
    serve     = string
  })
}

# ✅ Reference an existing monitor by name (we do NOT create it in TF)
variable "resource_monitor_name" {
  type    = string
  default = "RM_CUSTOMER360"   # set to "" to attach none
}

# ❌ Old input that caused interactive prompts — keep only if you really need it.
#    Make it nullable so TF never prompts in CI.
variable "resource_monitor" {
  type    = any
  default = null
}