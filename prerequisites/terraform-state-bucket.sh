PROJECT_ID="storied-box-478112-e8"
REGION="europe-west4"   # or your preferred region
TF_BUCKET="datahub-tf-state-bucket-${PROJECT_ID}"   # bucket name must be globally unique
TF_SA="datahub-automation-sa@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud storage buckets create "gs://${TF_BUCKET}" \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --uniform-bucket-level-access

gcloud storage buckets add-iam-policy-binding "gs://${TF_BUCKET}" \
  --member="serviceAccount:${TF_SA}" \
  --role="roles/storage.objectAdmin"