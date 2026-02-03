terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  required_version = ">= 1.5.0"
}

# =========================
# Variables
# =========================
variable "project_id" {
  description = "GCP Project ID"
  type        = string
  default = "project-ca896fcb-d1a8-4e3c-94d"
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "jenkins-vm"
}

variable "machine_type" {
  description = "GCP VM machine type"
  type        = string
  default     = "e2-medium"
}

variable "artifact_url" {
  description = "GCS URL or Artifact Registry URL for the JAR"
  type        = string
  default = "https://us-central1-maven.pkg.dev/project-ca896fcb-d1a8-4e3c-94d/test-jenkins/com/demo/jenkins-demo/1.0/jenkins-demo-1.0.jar"
}

# =========================
# Random suffix for uniqueness
# =========================
resource "random_id" "vm_suffix" {
  byte_length = 2
}

# =========================
# Compute VM
# =========================
resource "google_compute_instance" "jenkins_vm" {
  name         = "${var.vm_name}-${random_id.vm_suffix.hex}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20230214" # Latest Debian image
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {} # Assign ephemeral public IP
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y wget apt-transport-https curl

    # Install Java 21 (Adoptium)
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo tee /etc/apt/trusted.gpg.d/adoptium.asc
    echo "deb https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
    sudo apt update
    sudo apt install -y temurin-21-jdk

    # Create a directory for the app
    mkdir -p /opt/app
    cd /opt/app

    # Download the JAR from Artifact Registry
    # Using curl + Bearer token
    ACCESS_TOKEN=$(gcloud auth print-access-token)
    curl -H "Authorization: Bearer $ACCESS_TOKEN" -o jenkins-demo.jar "${var.artifact_url}"

    # Run the JAR (optional)
    java -jar jenkins-demo.jar &
  EOT

  tags = ["http-server"]
}

# =========================
# Outputs
# =========================
output "vm_public_ip" {
  value = google_compute_instance.jenkins_vm.network_interface[0].access_config[0].nat_ip
}

output "vm_name" {
  value = google_compute_instance.jenkins_vm.name
}
