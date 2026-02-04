resource "google_cloud_run_service" "app" {
  name     = var.cloud_run_service_name
  location = var.region

  template {
    spec {
      containers {
        image = var.service_image
        ports {
          container_port = 8080
        }
      }
      service_account_name = "jenkins-sa@${var.project_id}.iam.gserviceaccount.com"
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  service    = google_cloud_run_service.app.name
  location   = var.region
  role       = "roles/run.invoker"
  member     = "allUsers"
}

resource "google_pubsub_topic" "service_a_topic" {
  name = var.pubsub_topic_name
}

resource "google_cloudfunctions_function" "service_b" {
  name        = var.cloud_function_name
  description = "Triggered by Service A Pub/Sub"
  runtime     = "python311"
  region      = var.region
  entry_point = "hello_pubsub"

  source_archive_bucket = google_storage_bucket.functions_bucket.name
  source_archive_object = google_storage_bucket_object.functions_archive.name
  trigger_topic         = google_pubsub_topic.service_a_topic.name
}

resource "google_storage_bucket" "functions_bucket" {
  name     = "${var.project_id}-functions-bucket"
  location = var.region
}

resource "google_storage_bucket_object" "functions_archive" {
  name   = "service-b.zip"
  bucket = google_storage_bucket.functions_bucket.name
  source = "../service-b/service-b.zip"
}
