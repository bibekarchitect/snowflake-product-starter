variable "network_self_link" {
  description = "Self-link of the VPC network to attach CloudSQL private service connection"
  type        = string
}

variable "allocated_ip_range" {
  description = "Name of the allocated IP range (VPC Peering range) for private service connection"
  type        = string
}

variable "instance_name" {
  description = "CloudSQL instance name"
  type        = string
}

variable "region" {
  description = "Region where the CloudSQL instance will be deployed"
  type        = string
  default     = "asia-south1"
}

variable "tier" {
  description = "CloudSQL machine tier (e.g., db-f1-micro, db-custom-1-3840)"
  type        = string
  default     = "db-custom-1-3840"
}

variable "db_name" {
  description = "Name of the default database to create in the CloudSQL instance"
  type        = string
}

variable "db_user" {
  description = "Database user name"
  type        = string
}

variable "db_pass" {
  description = "Password for the CloudSQL user"
  type        = string
  sensitive   = true
}
