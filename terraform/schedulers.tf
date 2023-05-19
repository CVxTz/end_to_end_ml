resource "google_service_account" "download_parquet_scheduler_sa" {
  account_id   = "download-parquet-scheduler"
  display_name = "download parquet scheduler"
}

resource "google_cloud_scheduler_job" "download-parquet-scheduler" {
  name        = "download-parquet-scheduler"
  description = "Download parquet scheduler"
  schedule    = "0 0 5 * *"
  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions_function.parquet_to_bigquery_cloud_function.https_trigger_url
    headers     = {
      Content-Type = "application/json"
    }
    body = base64encode("{}")
    oidc_token {
      service_account_email = google_service_account.download_parquet_scheduler_sa.email
    }
  }
}