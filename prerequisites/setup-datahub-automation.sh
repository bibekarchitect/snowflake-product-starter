#!/usr/bin/env bash
set -euo pipefail

### ========= CONFIGURE THESE ==========

# Your new project
PROJECT_ID="storied-box-478112-e8"
BILLING_ACCOUNT_ID="";  # optional – only if you want to link billing via script

# Region / zone for infra (adjust to what you plan for GKE)
REGION="europe-west4"
ZONE="europe-west4-a"

# Names
AUTOMATION_SA_NAME="datahub-automation-sa"
AUTOMATION_SA_DISPLAY="DataHub Automation SA (Terraform + GitHub Actions)"
GITHUB_WIF_POOL="github-pool"
WORKLOAD_ID_POOL_DISPLAY="GitHub Actions Workload Identity Pool"
WORKLOAD_ID_PROVIDER_ID="github-provider"
WORKLOAD_ID_PROVIDER_DISPLAY="GitHub Actions OIDC Provider"

# GitHub repo used for CI/CD (owner/repo)
# Example: "bibekarchitect/datahub-gcp"
GITHUB_REPO="bibekarchitect/snowflake-product-starter"

### ====================================

echo "==> Setting gcloud project"
gcloud config set project "${PROJECT_ID}"

if [[ -n "${BILLING_ACCOUNT_ID}" ]]; then
  echo "==> Linking billing account (if not already linked)"
  gcloud beta billing projects link "${PROJECT_ID}" \
    --billing-account="${BILLING_ACCOUNT_ID}" || true
fi

echo "==> Enabling required APIs"
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  cloudresourcemanager.googleapis.com \
  sqladmin.googleapis.com \
  servicenetworking.googleapis.com \
  artifactregistry.googleapis.com \
  storage.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com

echo "==> Creating automation Service Account: ${AUTOMATION_SA_NAME}"
gcloud iam service-accounts create "${AUTOMATION_SA_NAME}" \
  --display-name "${AUTOMATION_SA_DISPLAY}" \
  --project "${PROJECT_ID}" || true

AUTOMATION_SA_EMAIL="${AUTOMATION_SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Service Account email: ${AUTOMATION_SA_EMAIL}"

echo "==> Granting IAM roles to automation SA (project-level)"

# Core infra + GKE + networking
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${AUTOMATION_SA_EMAIL}" \
  --role="roles/editor"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${AUTOMATION_SA_EMAIL}" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${AUTOMATION_SA_EMAIL}" \
  --role="roles/container.admin"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${AUTOMATION_SA_EMAIL}" \
  --role="roles/servicenetworking.networksAdmin"

# Cloud SQL (for MySQL metadata DB)
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${AUTOMATION_SA_EMAIL}" \
  --role="roles/cloudsql.admin"

# Artifact Registry / Container Registry access
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${AUTOMATION_SA_EMAIL}" \
  --role="roles/artifactregistry.admin"

# Storage (for TF state or buckets you may use)
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${AUTOMATION_SA_EMAIL}" \
  --role="roles/storage.admin"

# IAM management (for creating/binding SAs to GKE, etc.)
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${AUTOMATION_SA_EMAIL}" \
  --role="roles/iam.serviceAccountAdmin"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${AUTOMATION_SA_EMAIL}" \
  --role="roles/iam.serviceAccountUser"

# Logging/Monitoring (for TF and CI/CD observability)
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${AUTOMATION_SA_EMAIL}" \
  --role="roles/logging.admin"

gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${AUTOMATION_SA_EMAIL}" \
  --role="roles/monitoring.admin"

echo "==> Creating Workload Identity Pool: ${GITHUB_WIF_POOL}"

gcloud iam workload-identity-pools create "${GITHUB_WIF_POOL}" \
  --location="global" \
  --display-name="${GITHUB_WIF_POOL}" \
  --description="OIDC pool for GitHub Actions" || true

POOL_FULL_ID=$(gcloud iam workload-identity-pools describe "${GITHUB_WIF_POOL}" \
  --location="global" \
  --format="value(name)")

echo "Pool full resource name: ${POOL_FULL_ID}"

echo "==> Creating Workload Identity Provider: ${WORKLOAD_ID_PROVIDER_ID}"

gcloud iam workload-identity-pools providers create-oidc "${WORKLOAD_ID_PROVIDER_ID}" \
  --location="global" \
  --workload-identity-pool="${GITHUB_WIF_POOL}" \
  --display-name="${WORKLOAD_ID_PROVIDER_DISPLAY}" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --allowed-audiences="https://github.com/${GITHUB_REPO}" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.actor" \
  --attribute-condition="assertion.repository=='${GITHUB_REPO}'" || true

PROVIDER_FULL_ID="projects/$(gcloud config get-value project)/locations/global/workloadIdentityPools/${GITHUB_WIF_POOL}/providers/${WORKLOAD_ID_PROVIDER_ID}"

echo "Provider full resource name: ${PROVIDER_FULL_ID}"

echo "==> Allowing identities from the pool to impersonate the automation SA"

gcloud iam service-accounts add-iam-policy-binding "${AUTOMATION_SA_EMAIL}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/${POOL_FULL_ID}/attribute.repository/${GITHUB_REPO}"

echo
echo "========================================================="
echo " SETUP COMPLETE"
echo "========================================================="
echo
echo "Project ID:             ${PROJECT_ID}"
echo "Region:                 ${REGION}"
echo "Zone:                   ${ZONE}"
echo "Automation SA Email:    ${AUTOMATION_SA_EMAIL}"
echo "Workload Pool:          ${POOL_FULL_ID}"
echo "Workload Provider:      ${PROVIDER_FULL_ID}"
echo "GitHub Repo:            ${GITHUB_REPO}"
echo
echo "Use these in your GitHub Actions workflow, for example:"
cat <<EOF

  permissions:
    id-token: write
    contents: read

  env:
    GCP_PROJECT_ID: ${PROJECT_ID}
    GCP_WORKLOAD_IDENTITY_PROVIDER: ${PROVIDER_FULL_ID}
    GCP_SERVICE_ACCOUNT: ${AUTOMATION_SA_EMAIL}

  steps:
    - name: Authenticate to GCP
      uses: google-github-actions/auth@v2
      with:
        workload_identity_provider: \${{ env.GCP_WORKLOAD_IDENTITY_PROVIDER }}
        service_account: \${{ env.GCP_SERVICE_ACCOUNT }}

    - name: Set up gcloud
      uses: google-github-actions/setup-gcloud@v2
      with:
        project_id: \${{ env.GCP_PROJECT_ID }}

    - name: Terraform Init / Plan / Apply
      run: |
        terraform init
        terraform plan
        # terraform apply -auto-approve

EOF

echo "========================================================="
echo "Now plug these values into:"
echo "  * Your Terraform backend/config"
echo "  * Your GitHub Actions workflow (env vars above)"
echo "========================================================="