variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "Artifact Registry region (e.g. us-central1)"
}

variable "repository_name" {
  type        = string
  description = "Repository name"
}

variable "description" {
  type        = string
  default     = "Docker registry for application images"
}

variable "labels" {
  type    = map(string)
  default = {}
}

variable "service_accounts" {
  type        = map(string)
  default     = {}
  description = "Map of service accounts allowed to push/pull images"
}