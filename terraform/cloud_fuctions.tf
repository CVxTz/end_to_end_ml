resource "local_file" "requirements" {
  content  = file("${local.base_path}/requirements-etl.txt")
  filename = "${local.base_path}/src/etl/requirements.txt"
}

resource "google_storage_bucket" "cloud_function_bucket" {
  name     = "${var.project_id}-cloud-function-bucket"
  location = "EUROPE-WEST1"
}

data "archive_file" "parquet_to_bigquery_zip" {
  type        = "zip"
  output_path = "/tmp/parquet_to_bigquery.zip"
  source_dir  = "${local.base_path}/src/etl/"

  # It is important to this process.
  depends_on = [
    local_file.requirements
  ]
}

resource "google_storage_bucket_object" "parquet_to_bigquery_archive" {
  name       = "parquet_to_bigquery-${data.archive_file.parquet_to_bigquery_zip.output_base64sha256}.zip"
  bucket     = google_storage_bucket.cloud_function_bucket.name
  source     = data.archive_file.parquet_to_bigquery_zip.output_path
  depends_on = [
    data.archive_file.parquet_to_bigquery_zip
  ]
}

resource "google_cloudfunctions_function" "parquet_to_bigquery_cloud_function" {
  name        = "parquet-to-bigquery-cloud-function"
  description = "parquet-to-bigquery-cloud-function"
  runtime     = "python39"

  available_memory_mb          = 2048
  source_archive_bucket        = google_storage_bucket.cloud_function_bucket.name
  source_archive_object        = google_storage_bucket_object.parquet_to_bigquery_archive.name
  trigger_http                 = true
  https_trigger_security_level = "SECURE_ALWAYS"
  timeout                      = 540
  entry_point                  = "download_parquet"
  environment_variables        = {
    GCP_PROJECT = var.project_id
    TABLE       = var.table
  }
}

resource "google_cloudfunctions_function_iam_member" "invoker" {
  cloud_function = google_cloudfunctions_function.parquet_to_bigquery_cloud_function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "serviceAccount:${google_service_account.download_parquet_scheduler_sa.email}"
}