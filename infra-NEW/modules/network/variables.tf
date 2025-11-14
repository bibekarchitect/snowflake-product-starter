variable "network_name" {
  description = "Name of the VPC network to create"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet to create within the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "Primary CIDR block for the subnet"
  type        = string
}

variable "region" {
  description = "Region where the subnet and IP ranges will be created"
  type        = string
  default     = "asia-south1"
}

variable "ip_range_pods" {
  description = "Secondary CIDR block for GKE pod IPs"
  type        = string
}

variable "ip_range_svc" {
  description = "Secondary CIDR block for GKE service IPs"
  type        = string
}
