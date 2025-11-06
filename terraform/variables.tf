# -------- Provider auth/context (explicit) --------
variable "snowflake_account" {
  description = "Snowflake account locator (e.g., UE47735)"
  type        = string
}

variable "snowflake_region" {
  description = "Snowflake region in normalized form (e.g., europe-west4.gcp)"
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake username (e.g., CICD_BOT)"
  type        = string
}

variable "snowflake_password" {
  description = "Snowflake password for the user"
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "Active role for provider session (e.g., CICD_SNOWFLAKE_DEPLOY)"
  type        = string
}

# -------- Product configuration (your existing vars) --------
variable "create_database" {
  type    = bool
  default = false
}

variable "database_name" {
  type    = string
  default = "CUSTOMER360_DEV"

  validation {
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
  default = "RM_CUSTOMER360"   # set "" to attach none
}

# Keep for compatibility if referenced anywhere (not used to create RM)
variable "resource_monitor" {
  type    = any
  default = null
}