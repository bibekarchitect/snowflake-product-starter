variable "project_id" {
  type = string
}

variable "gke_namespace" {
  type    = string
  default = "datahub"
}

variable "gke_service_account_name" {
  type    = string
  default = "datahub-gms"
}