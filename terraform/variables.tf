variable "project_id" {
  default = "project-ca896fcb-d1a8-4e3c-94d"
}

variable "region" {
  default = "us-central1"
}

variable "image_uri" {
  description = "Docker image from Artifact Registry"
  type        = string
}
