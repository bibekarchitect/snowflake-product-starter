# ---- Provider inputs passed from GitHub Actions ----
variable "snowflake_account" {
  type = string
}

variable "snowflake_region" {
  type = string
}

variable "snowflake_user" {
  type = string
}

variable "snowflake_password" {
  type      = string
  sensitive = true
}

variable "snowflake_role" {
  type = string
}

# ---- Product/config vars you already use ----
variable "create_database" {
  type    = bool
  default = false
}

variable "database_name" {
  type    = string
  default = "CUSTOMER360_DEV"

  validation {
    # use two-arg trim to avoid earlier error
    condition     = length(trim(var.database_name, " ")) > 0
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

variable "resource_monitor_name" {
  type    = string
  default = "RM_CUSTOMER360"
}

variable "resource_monitor" {
  type    = any
  default = null
}