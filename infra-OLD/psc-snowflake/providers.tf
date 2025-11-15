provider "google" {
  project = var.project_id
  region  = var.region
}
provider "google-beta" {
  project = var.project_id
  region  = var.region
}

terraform {
      backend "gcs" {
        bucket = "tw-tf-state-prod"
        prefix = "terraform/psc-state" # Optional: specify a path within the bucket
      }
    }