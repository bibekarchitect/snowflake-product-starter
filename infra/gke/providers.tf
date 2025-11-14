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
        bucket = "datahub-tf-state-bucket-${{ secrets.GCP_PROJECT_ID }}"
        prefix = "terraform-states/gke-state" # Optional: specify a path within the bucket
      }
    }