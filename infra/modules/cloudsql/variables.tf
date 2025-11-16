// infra/modules/cloudsql/variables.tf

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "env" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}

variable "region" {
  description = "Region for Cloud SQL instance"
  type        = string
}

variable "network_self_link" {
  description = "Self link of the VPC network used for private IP"
  type        = string
}

variable "allocated_ip_range" {
  description = "Name of the reserved range for private service networking"
  type        = string
  // e.g. "dev-datahub-mysql-psn-range"
}

variable "tier" {
  description = "Cloud SQL machine tier (e.g. db-custom-1-3840)"
  type        = string
  default     = "db-custom-1-3840"
}

variable "db_name" {
  description = "Database name inside the instance"
  type        = string
  default     = "datahub"
}

variable "db_user" {
  description = "Database user name"
  type        = string
  default     = "datahub_app"
}

variable "db_pass" {
  type        = string
  description = "DB password for app user"
}

variable "instance_name" {
  description = "Cloud SQL instance name"
  type        = string
}