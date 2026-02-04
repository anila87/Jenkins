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
  name        = "service-b"
  description = "Cloud Function subscriber for service-a Pub/Sub"
  runtime     = "python311"
  entry_point = "main"   # your Python function entry
  source_archive_bucket = "test-run1a"
  source_archive_object = "service-b.zip"
  region      = var.region
  service_account_email = "jenkins-sa@project-ca896fcb-d1a8-4e3c-94d.iam.gserviceaccount.com"

  # NEW event_trigger block
  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_topic.service_a_topic.id
  }
}


resource "google_storage_bucket" "functions_bucket" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
}


resource "google_storage_bucket_object" "functions_archive" {
  name   = "service-b.zip"
  bucket = google_storage_bucket.functions_bucket.name
  source = "../service-b/service-b.zip"
}
