
variable "project_id" {
  description = "GCP project ID where IAM prerequisites will be created"
  type        = string
}

variable "automation_sa_name" {
  description = "Service account ID (without domain) to be created for automation"
  type        = string
}

variable "automation_sa_display_name" {
  description = "Display name for the automation service account"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository in the format owner/repo for Workload Identity Provider (e.g. bibekarchitect/snowflake-product-starter)"
  type        = string
}

variable "wif_pool_id" {
  description = "Workload Identity Pool ID (not full resource name)"
  type        = string
}

variable "wif_pool_display_name" {
  description = "Display name for the Workload Identity Pool"
  type        = string
  default     = "GitHub Actions Workload Identity Pool"
}

variable "wif_provider_id" {
  description = "Workload Identity Provider ID (not full resource name)"
  type        = string
}

variable "wif_provider_display_name" {
  description = "Display name for the Workload Identity Provider"
  type        = string
  default     = "GitHub Actions OIDC Provider"
}