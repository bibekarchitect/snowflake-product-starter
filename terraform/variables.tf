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
  default = "RM_CUSTOMER360"
}

variable "resource_monitor" {
  type    = any
  default = null
}