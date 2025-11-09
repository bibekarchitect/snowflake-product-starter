terraform {
  required_version = ">= 1.6.0"
  backend "gcs" {}
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.26.0"
    }
  }
}

terraform {
      backend "gcs" {
        bucket = "tw-tf-state-prod"
        prefix = "terraform/gke-psc-state" # Optional: specify a path within the bucket
      }
    }