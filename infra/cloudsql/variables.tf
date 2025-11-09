variable "project_id" {
  type = string
  description = "GCP project ID where the CloudSQL and GKE resources will be created"
}

variable "region" {
  type        = string
  description = "Region for deployment, e.g. europe-west4"
  default     = "europe-west4"
}

# Existing VPC & Subnet used by GKE (self_links recommended)
variable "network" {
  type        = string
  description = "VPC self link where CloudSQL private IP will connect"
}

variable "subnet" {
  type        = string
  description = "Subnet self link used for CloudSQL private connection"
}

# Names & sizing
variable "instance_name" {
  type        = string
  description = "Name of the CloudSQL instance"
  default     = "datahub-mysql"
}

variable "db_name" {
  type        = string
  description = "Database name for DataHub metadata store"
  default     = "datahub"
}

variable "db_user" {
  type        = string
  description = "Database username for DataHub application"
  default     = "datahub_app"
}

variable "db_pass" {
  type        = string
  description = "Password for the database user"
  sensitive   = true
}

# Private IP range for Service Networking
variable "allocated_ip_range" {
  type        = string
  description = "Name of the allocated IP range for private service connection"
  default     = "google-managed-services-datahub"
}