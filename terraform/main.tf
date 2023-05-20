
terraform {
  backend "gcs" {
    bucket  = "end-to-end-ml-terraform-state"
    prefix  = "dev"
  }
}


provider "google" {
  project = var.project_id
  region  = "europe-west1"
}

locals {
  base_path = abspath("${path.module}/..")
}