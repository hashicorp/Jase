terraform {
  required_version = ">=0.14 "
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.1.0"
    }
  }
}

# data "vault_generic_secret" "gcp_secret" {
#   path = "gcp/token/token-roleset"
# }

provider "google" {
  project = var.gcp_project
  # region = var.gcp_region
}

