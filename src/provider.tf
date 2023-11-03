# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "google" {
    project     = var.project_id
    zone        = local.zone
    credentials = file(var.credentials_file)
}

# Configure Kubernetes provider with OAuth2 access token
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {
    depends_on = [
        module.gcp_gke
    ]
}

provider "kubernetes" {
    host = "https://${module.gcp_gke.host}"

    token                  = data.google_client_config.default.access_token
    client_certificate     = base64decode(module.gcp_gke.client_certificate)
    client_key             = base64decode(module.gcp_gke.client_key)
    cluster_ca_certificate = base64decode(module.gcp_gke.cluster_ca_certificate)
}

provider "helm" {
    kubernetes {
        host = "https://${module.gcp_gke.host}"

        token                  = data.google_client_config.default.access_token
        client_certificate     = base64decode(module.gcp_gke.client_certificate)
        client_key             = base64decode(module.gcp_gke.client_key)
        cluster_ca_certificate = base64decode(module.gcp_gke.cluster_ca_certificate)
    }
}

provider "kubectl" {
    host             = "https://${module.gcp_gke.host}"
    load_config_file = false

    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gcp_gke.cluster_ca_certificate)
}