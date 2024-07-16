# -------------------------------------------------------------------------------------
# This configuration sets up a service account with the necessary IAM roles,
# creates a VPC network and subnet, launches a VM instance with SSH access, and
# creates a cloud storage bucket with appropriate access controls.
# Adjust the values for SSH key, and any other specifics to fit with requirements.
# -------------------------------------------------------------------------------------
variable "gcp_project_id" {
  type     = string
  nullable = false
}
# https://cloud.google.com/compute/docs/regions-zones/#identifying_a_region_or_zone
variable "region" {
  type    = string
  default = "asia-east2"
}
variable "zone" {
  type    = string
  default = "asia-east2-a"
}

variable "user_name" {
  type    = string
  default = "developer"
}
variable "ssh_pub" {
  type     = string
  nullable = false
}
variable "init_file" {
  type     = string
  nullable = false
}

variable "bucket_name" {
  type     = string
  nullable = false
}


# -------------------------------------------------------------------------------------
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.35.0"
    }
  }

  required_version = ">= 1.2.0"
}


provider "google" {
  project = var.gcp_project_id

  region = var.region
  default_labels = {
    demo = "terraform"
  }
}

# -----------------------------------------------------------------------------
# IAM - Service Account
resource "google_service_account" "terraform_service_account" {
  account_id   = "terraform-service-account"
  display_name = "Terraform Service Account"
  description  = "created for demo"
}

resource "google_project_iam_member" "service_account_role" {
  project = var.gcp_project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.terraform_service_account.email}"

  depends_on = [
    google_service_account.terraform_service_account
  ]
}

# -----------------------------------------------------------------------------
# VM - Compute Instance
resource "google_compute_instance" "app_server" {
  name         = "terraform-instance"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
    auto_delete = true
  }

  network_interface {
    # network = "default"
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {} # ephemeral public IP
  }

  service_account {
    email  = google_service_account.terraform_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  # https://developer.hashicorp.com/terraform/language/expressions/strings
  metadata = {
    "ssh-keys" = <<EOT
    ${var.user_name}:${file(var.ssh_pub)} ${var.user_name}
  EOT
  }

  metadata_startup_script = file(var.init_file)

  # # (last resort, less efficient) create website via provisioner with customization
  # connection {
  #   type        = "ssh"
  #   host        = google_compute_instance.app_server.network_interface.0.access_config.0.nat_ip
  #   port        = 22
  #   user        = var.user_name
  #   private_key = file("~/.ssh/<private_key>")
  # }

  # # provide file for initialization
  # provisioner "file" {
  #   source      = var.init_file
  #   destination = "/tmp/init.sh"
  # }

  # # execute the initialization script
  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /tmp/init.sh",
  #     "/tmp/init.sh",
  #   ]
  # }

  # firewall linked with tag for SSH traffic
  tags = ["allow-ssh"]
  labels = {
    name = "demo_terraform"
  }
}

# -----------------------------------------------------------------------------
# VPC - Computer Network
# require "Compute Engingine API" to be enabled
resource "google_compute_network" "vpc_network" {
  name                    = "terraform-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "terraform-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_router" "router" {
  name    = "terraform-router"
  network = google_compute_network.vpc_network.id
  region  = var.region
}

resource "google_compute_router_nat" "nat" {
  name                               = "terraform-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# set up traffic through Firewall
# config to allow SSH, combined with HTTP with cause unexpected issue
resource "google_compute_firewall" "allow_ssh" {
  name        = "terraform-ssh"
  network     = google_compute_network.vpc_network.name
  description = "Allow SSH traffic"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] # allow from anywhere

  target_tags = ["allow-ssh"]
}
# config to allow HTTP and HTTPS
resource "google_compute_firewall" "allow_http" {
  name        = "terraform-http"
  network     = google_compute_network.vpc_network.name
  description = "Allow HTTP and HTTPS traffic"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  source_ranges = ["0.0.0.0/0"] # allow from anywhere
}
# -----------------------------------------------------------------------------
# Storage Bucket
# https://cloud.google.com/storage/docs/locations
resource "google_storage_bucket" "terraform_bucket" {
  name     = var.bucket_name
  location = upper(var.region)

  labels = {
    name = "terraform-bucket"
  }
}

resource "google_storage_bucket_iam_member" "bucket_policy" {
  bucket = google_storage_bucket.terraform_bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.terraform_service_account.email}"
}
