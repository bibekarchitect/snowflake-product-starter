terraform {
      backend "gcs" {
        bucket = "tw-tf-state-prod"
        prefix = "terraform/cloudsql" # Optional: specify a path within the bucket
      }
    }
