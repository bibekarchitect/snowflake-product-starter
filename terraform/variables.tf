terraform {
  required_version = ">= 1.6.0"
}

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

variable "resource_monitor_name" {
  type    = string
  default = "RM_CUSTOMER360"   # set "" to attach none
}

# Keep null so TF never prompts in CI even if referenced somewhere old
variable "resource_monitor" {
  type    = any
  default = null
}