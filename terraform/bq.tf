resource "google_bigquery_dataset" "default" {
  dataset_id    = "end_to_end_ml"
  friendly_name = "end_to_end_ml"
  description   = "End to End ML dataset"
  location      = "EU"

  labels = {
    env = "default"
  }
}

resource "google_bigquery_table" "default" {
  dataset_id          = google_bigquery_dataset.default.dataset_id
  table_id            = "taxi_duration"
  deletion_protection = false
  labels              = {
    env = "default"
  }

  schema = file("${local.base_path}/src/etl/schema.json")

}