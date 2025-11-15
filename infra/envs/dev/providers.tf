terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

  backend "gcs" {}
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  # Required for Workload Identity Federation (GitHub Actions)
  #impersonate_service_account = var.terraform_service_account
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

#   impersonate_service_account = var.terraform_service_account
}