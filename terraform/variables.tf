variable "account" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "role" {
  type = string
}

variable "region" {
  type = string
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

