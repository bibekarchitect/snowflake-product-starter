variable "project_id" {
  description = "GCP project ID where resources will be created"
  type        = string
}

variable "region" {
  description = "GCP region where the subnet will be created"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet inside the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the primary subnet"
  type        = string
}

variable "ip_range_pods" {
  description = "Secondary IP range for GKE Pods"
  type        = string
}

variable "ip_range_svc" {
  description = "Secondary IP range for GKE Services"
  type        = string
}
variable "env" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}
variable "zone" {
  description = "GCP zone where resources will be created"
  type        = string
}
variable "allocated_ip_range" {
  description = "Name of the reserved range for private service networking"
  type        = string
  // e.g. "dev-datahub-mysql-psn-range"
}
variable "instance_name" {
  description = "Cloud SQL instance name"
  type        = string
}

variable "gke_machine_type" {
  description = "GKE Machine Type"
  type        = string
}

variable "gke_min_nodes" {
  description = "GKE minimum node count"
  type        = number
}

variable "gke_max_nodes" {
  description = "GKE maximum node count"
  type        = number
}
variable "deletion_protection" {
  description = "node deletion protection"
  type = bool
}

variable "db_name" {
  description = "Database name for the Cloud SQL instance"
  type        = string
  default     = "my_database"
}

variable "db_user" {
  description = "Database username for the Cloud SQL instance"
  type        = string
  default     = "dbadmin"
}

variable "db_pass" {
  type        = string
  description = "Password for datahub_app MySQL user"
}

variable "tier" {
  description = "Machine type / service tier for the Cloud SQL instance (e.g. db-n1-standard-1)"
  type        = string
  default     = "db-n1-standard-1"
}

variable "gke_cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "gke-cluster"
}