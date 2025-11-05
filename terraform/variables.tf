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