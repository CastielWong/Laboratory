
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.35.0"
    }
  }

  required_version = ">= 1.2.0"
}

variable "gcp_project_id" {
    type = string
    nullable = false
}


provider "google" {
  project = var.gcp_project_id

  region = "ap-east2-a"
  default_labels = {
    DEMO = "Terraform"
  }
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"

  # project = var.gcp_project_id
}

# This configuration sets up a service account with the necessary IAM roles,
# creates a VPC network and subnet, launches a Compute Engine instance with
# SSH access, and creates a Cloud Storage bucket with appropriate access controls.
# Adjust the values for your project, region, and any other specifics to
# fit your requirements.

# -----------------------------------------------------------------------------
# # IAM
# resource "google_service_account" "terraform_service_account" {
#   account_id   = "terraform-service-account"
#   display_name = "Terraform Service Account"

#   labels = {
#     Name = "TerraformUser"
#   }
# }

# resource "google_project_iam_member" "service_account_role" {
#   project = var.project
#   role    = "roles/editor"
#   member  = "serviceAccount:${google_service_account.terraform_service_account.email}"

#   depends_on = [
#     google_service_account.terraform_service_account
#   ]
# }

# # -----------------------------------------------------------------------------
# # Compute Instance
# resource "google_compute_instance" "app_server" {
#   name         = "terraform-instance"
#   machine_type = "e2-micro"
#   zone         = "ap-southeast-1-a"

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-10"
#     }
#   }

#   network_interface {
#     network       = google_compute_network.vpc_network.id
#     subnetwork    = google_compute_subnetwork.subnet.id
#     access_config {}  # ephemeral public IP
#   }

#   service_account {
#     email  = google_service_account.terraform_service_account.email
#     scopes = ["https://www.googleapis.com/auth/cloud-platform"]
#   }

#   tags = ["allow-ssh"]

#   labels = {
#     Name = "DemoTerraform"
#   }
# }

# # -----------------------------------------------------------------------------
# # VPC
# resource "google_compute_network" "vpc_network" {
#   name                    = "terraform-vpc"
#   auto_create_subnetworks = false

#   labels = {
#     Name = "terraform-vpc"
#   }
# }

# resource "google_compute_subnetwork" "subnet" {
#   name          = "terraform-subnet"
#   ip_cidr_range = "10.0.1.0/24"
#   region        = "ap-southeast-1"
#   network       = google_compute_network.vpc_network.id

#   labels = {
#     Name = "terraform-subnet"
#   }
# }

# resource "google_compute_router" "router" {
#   name    = "terraform-router"
#   network = google_compute_network.vpc_network.id
#   region  = "ap-southeast-1"

#   labels = {
#     Name = "terraform-router"
#   }
# }

# resource "google_compute_router_nat" "nat" {
#   name     = "terraform-nat"
#   router   = google_compute_router.router.name
#   region   = "ap-southeast-1"
#   nat_ip_allocate_option = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

#   labels = {
#     Name = "terraform-nat"
#   }
# }

# # -----------------------------------------------------------------------------
# # Firewall
# resource "google_compute_firewall" "allow_ssh" {
#   name    = "terraform-ssh"
#   network = google_compute_network.vpc_network.name

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   source_ranges = ["0.0.0.0/0"]  # Allow SSH from anywhere

#   target_tags = ["allow-ssh"]

#   labels = {
#     Name = "DemoTerraform"
#   }
# }

# # -----------------------------------------------------------------------------
# # Storage Bucket
# resource "google_storage_bucket" "terraform_bucket" {
#   name     = "terraform-caswexp2024q2"
#   location = ""

#   labels = {
#     Name = "terraform_bucket"
#   }
# }

# resource "google_storage_bucket_iam_member" "bucket_policy" {
#   bucket = google_storage_bucket.terraform_bucket.name
#   role   = "roles/storage.admin"
#   member = "serviceAccount:${google_service_account.terraform_service_account.email}"
# }
