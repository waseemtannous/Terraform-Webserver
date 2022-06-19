terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.20.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

provider "docker" {
  # exposed deamon port (docker)
  host = "tcp://localhost:2375"

  registry_auth {
    address = "gcr.io"
    # found in username/.docker/config.json
    config_file = pathexpand("config.json")
  }
}

provider "google" {
  credentials = file(var.service_account_json)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  credentials = file(var.service_account_json)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

# base image used to run on VMs(container optimized os)
data "google_compute_image" "cos_image" {
  family  = var.base_image_family
  project = var.base_image_project
}

###########################################################
# DATABASE

# build docker image
resource "docker_image" "database_docker_build" {
  name = var.database_container_name

  build {
    path = "database"
  }
}

# database docker image
resource "docker_registry_image" "database-image" {
  name = docker_image.database_docker_build.name
}

resource "google_compute_firewall" "default-firewall" {
  name    = "firewall"
  network = var.network

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [var.database_container_port]
  }

  allow {
    protocol = "udp"
    ports    = [var.database_container_port]
  }
}

# new VM for database
resource "google_compute_instance" "database" {
  name         = "database"
  machine_type = var.server_template_machine_type

  tags = ["ssh", "http-server", "https-server"]

  metadata = {
    gce-container-declaration = "spec:\n  containers:\n    - image: ${docker_registry_image.database-image.name}\n      name: server-container\n      restartPolicy: Always\n\n"
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.cos_image.self_link
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {
    }
  }

  service_account {
    scopes = var.scopes
  }
}

###########################################################
# SERVER

# ----------------------- v1 --------------------------------
# build docker image
resource "docker_image" "server_v1_docker_build" {
  name = var.server_v1_container_name

  build {
    path = "server/v1"
  }
}

# server docker image v1
resource "docker_registry_image" "server-image-v1" {
  name = docker_image.server_v1_docker_build.name
}

# server-v1 container module
module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = docker_registry_image.server-image-v1.name
    env = [
      {
        name  = "DB_HOST"
        value = "${google_compute_instance.database.network_interface.0.access_config.0.nat_ip}"
      }
    ]
    restart_policy = "Always"
  }
}

# create server-v1 vm template
resource "google_compute_instance_template" "server-v1-template" {
  name         = "server-v1-template"
  machine_type = var.server_template_machine_type

  tags = ["ssh", "http-server", "https-server"]

  metadata = {
    gce-container-declaration = module.gce-container.metadata_value

  }

  disk {
    source_image = data.google_compute_image.cos_image.self_link
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    access_config {
    }
  }

  service_account {
    scopes = var.scopes
  }
}

# managed instance group
resource "google_compute_instance_group_manager" "server-group" {
  provider = google-beta
  name     = "server-group"
  zone     = var.zone

  version {
    instance_template = google_compute_instance_template.server-v1-template.id
    name              = "server-image"
  }

  base_instance_name = "server-node"

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_percent     = 0
    max_unavailable_fixed = 2
    min_ready_sec         = 50
    replacement_method    = "RECREATE"
  }
}

# managed instance group autoscaling policy
resource "google_compute_autoscaler" "autoscaler-policy" {
  name   = "server-autoscaler"
  zone   = var.zone
  target = google_compute_instance_group_manager.server-group.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = 60

    cpu_utilization {
      target = var.cpu_utilization
    }
  }
}
