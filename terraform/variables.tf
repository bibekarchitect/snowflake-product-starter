terraform {
  required_version = ">= 1.6.0"
}

# ---- Product config ----
variable "create_database" {
  type    = bool
  default = false
}

variable "database_name" {
  type    = string
  default = "CUSTOMER360_DEV"

  validation {
    condition     = length(trim(var.database_name, " ")) > 0
    error_message = "database_name must be non-empty or blank-only spaces."
  }
}

variable "warehouses" {
  type = object({
    ingest    = string
    transform = string
    serve     = string
  })
}

# Reference an existing monitor by name (we do NOT create it in TF)
variable "resource_monitor_name" {
  type    = string
  default = "RM_CUSTOMER360"   # set "" to attach none
}

# Legacy input that previously caused interactive prompts; keep nullable to avoid TF asking in CI.
variable "resource_monitor" {
  type    = any
  default = null
}