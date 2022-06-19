variable "project" {
  type    = string
  default = "terraform-webserver-prod"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-c"
}

variable "service_account_json" {
  type    = string
  default = "terraform-webserver-prod-service-account.json"
}

variable "server_template_machine_type" {
  type    = string
  default = "e2-medium"
}

variable "network" {
  type    = string
  default = "default"
}

variable "subnetwork" {
  type    = string
  default = "default"
}

variable "server_v1_container_name" {
  type    = string
  default = "gcr.io/terraform-webserver-prod/server:v1"
}

variable "server_v2_container_name" {
  type    = string
  default = "gcr.io/terraform-webserver-prod/server:v2"
}

variable "database_container_name" {
  type    = string
  default = "gcr.io/terraform-webserver-prod/database"
}

variable "database_container_port" {
  type    = string
  default = "5432"
}

variable "base_image_family" {
  type    = string
  default = "cos-stable"
}

variable "base_image_project" {
  type    = string
  default = "cos-cloud"
}

variable "min_replicas" {
  type    = number
  default = 1
}

variable "max_replicas" {
  type    = number
  default = 10
}

variable "cpu_utilization" {
  type    = number
  default = 0.8
}

variable "scopes" {
  type = list(string)
  default = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/pubsub",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/cloud-platform.read-only",
    "https://www.googleapis.com/auth/cloudplatformprojects",
    "https://www.googleapis.com/auth/cloudplatformprojects.readonly",
    "https://www.googleapis.com/auth/trace.append",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/bigquery",
    "https://www.googleapis.com/auth/datastore",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/trace.append",
    "https://www.googleapis.com/auth/source.full_control",
    "https://www.googleapis.com/auth/source.read_only",
    "https://www.googleapis.com/auth/compute.readonly"
  ]
}
