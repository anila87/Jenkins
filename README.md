# Jenkins CI/CD Pipeline for Docker on GCP

This repository demonstrates a full CI/CD workflow using Jenkins, Docker, Terraform, and Google Cloud Platform (GCP). The pipeline automates building a Docker image, pushing it to Artifact Registry, and deploying it to Cloud Run.

# Pipeline Overview

# 1.Source Code Checkout

Jenkins fetches the code from the Git repository.

# 2.GCP Authentication

Service Account (jenkins-sa) credentials are used to authenticate with GCP.

# 3.Docker Build

Jenkins builds a Docker image for the application.

# 4.Push to Artifact Registry

The Docker image is pushed to GCP Artifact Registry in the specified repository.

# 5.Deploy with Terraform

Terraform provisions a Cloud Run service using the Docker image from Artifact Registry.

# Prerequisites

# Jenkins with:

Docker installed

Terraform installed

Git installed

# GCP Project with:

Artifact Registry repository created

Service account (jenkins-sa) with roles:

Artifact Registry Admin

Cloud Run Admin

Compute Admin (if needed)

Service Account User (required for Cloud Run deployments)

Service Account JSON added to Jenkins credentials

# Configuration

Update Jenkinsfile:

Set GCP project ID, Artifact Registry repo, and Docker image tag.

Update main.tf:

Set Cloud Run service name, region, and Docker image reference.

# How to Run

Trigger the Jenkins pipeline manually or via SCM webhook.

Monitor stages in Jenkins:

Checkout → Build Docker Image → Push to Artifact Registry → Terraform Deploy Container

Once completed, Terraform outputs the Cloud Run URL.

Test the deployed service:

curl https://<cloud-run-url>

# Outputs

url – The public URL of the deployed Cloud Run service.

vm_name (if VM used for other purposes) – Name of the deployed VM/container host.

# Notes

Ensure Docker daemon is running and Jenkins user has permission to access it.

Cloud Run services are public by default unless authentication is enabled.

Adjust Terraform variables for region, service name, and Docker image tags as needed.
