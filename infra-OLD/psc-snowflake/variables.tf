variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "europe-west4"
}

variable "network" {
  description = "VPC self link"
  type        = string
}

variable "subnet" {
  description = "Subnet self link"
  type        = string
}

variable "snowflake_account_hostname" {
  type = string
}

variable "snowflake_service_attachment" {
  type = string
}

variable "dns_zone_domain" {
  type    = string
  default = "snowflakecomputing.com"
}

variable "dns_zone_name" {
  type    = string
  default = "snowflake-private-zone"
}