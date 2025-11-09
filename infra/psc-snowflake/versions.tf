terraform {
  required_version = ">= 1.6.0"

  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      # Pin at or above this — PSC fixes are recent
      version = ">= 7.10.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 7.10.0"
    }
  }
}
