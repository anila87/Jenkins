variable "project_id" {
  default = "project-ca896fcb-d1a8-4e3c-94d"
}

variable "region" {
  default = "us-central1"
}

variable "service_image" {
  default = "us-central1-docker.pkg.dev/project-ca896fcb-d1a8-4e3c-94d/docker-repo/service-a:v1"
}

variable "cloud_run_service_name" {
  default = "service-a"
}

variable "pubsub_topic_name" {
  default = "service-a-topic"
}

variable "cloud_function_name" {
  default = "service-b-func"
}
