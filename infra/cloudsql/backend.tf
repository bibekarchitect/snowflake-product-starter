terraform {
      backend "gcs" {
        bucket = "datahub-tf-state-bucket-${var.project_id}"
        prefix = "terraform-states/gke-state" # Optional: specify a path within the bucket
      }
    }

