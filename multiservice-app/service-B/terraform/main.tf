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
