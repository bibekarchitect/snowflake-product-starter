variable "gke_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "location" {
  description = "Region or zone where GKE cluster will be created"
  type        = string
}

variable "network_id" {
  description = "Self-link or ID of the VPC network for the GKE cluster"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet where GKE cluster will be deployed"
  type        = string
}

variable "gke_machine_type" {
  description = "Machine type for GKE node pool (e.g. e2-standard-2)"
  type        = string
  default     = "e2-standard-2"
}

variable "gke_min_nodes" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 0
}

variable "gke_max_nodes" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 1
}

variable "deletion_protection" {
  description = "Enable deletion protection for the GKE cluster"
  type        = bool
  default     = false
}

variable "project_id" {
  type = string
}