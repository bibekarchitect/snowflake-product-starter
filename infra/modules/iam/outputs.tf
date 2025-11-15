
output "automation_sa_email" {
  value = google_service_account.automation.email
}
output "wif_pool_name" {
  value = google_iam_workload_identity_pool.github_pool.name
}
output "wif_provider_name" {
  value = google_iam_workload_identity_pool_provider.github_provider.name
}
