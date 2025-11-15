variable "project_id" {
  description = "GCP project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "GCP region for regional resources"
  type        = string
  default     = "asia-south1"
}

variable "location" {
  description = "Location for GKE cluster (regional or zonal)"
  type        = string
  default     = "asia-south1"
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet for GKE and CloudSQL"
  type        = string
}

variable "subnet_cidr" {
  description = "Primary CIDR block for the subnet"
  type        = string
}

variable "ip_range_pods" {
  description = "Secondary IP CIDR range for GKE pods"
  type        = string
}

variable "ip_range_svc" {
  description = "Secondary IP CIDR range for GKE services"
  type        = string
}

variable "gke_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "gke_machine_type" {
  description = "Machine type for the GKE default node pool"
  type        = string
  default     = "e2-standard-2"
}

variable "gke_min_nodes" {
  description = "Minimum number of nodes for GKE autoscaling"
  type        = number
  default     = 0
}

variable "gke_max_nodes" {
  description = "Maximum number of nodes for GKE autoscaling"
  type        = number
  default     = 1
}

variable "allocated_ip_range" {
  description = "Name of the allocated IP range for CloudSQL private service connection"
  type        = string
}

variable "sql_instance_name" {
  description = "CloudSQL instance name"
  type        = string
}

variable "sql_tier" {
  description = "CloudSQL machine tier (e.g., db-f1-micro, db-custom-1-3840)"
  type        = string
  default     = "db-custom-1-3840"
}

variable "sql_db_name" {
  description = "CloudSQL database name"
  type        = string
}

variable "sql_db_user" {
  description = "CloudSQL user name"
  type        = string
}

variable "sql_db_pass" {
  description = "CloudSQL database user password"
  type        = string
  sensitive   = true
}