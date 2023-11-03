# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud-Native Application in a Kubernetes Cluster

#####################################################################
# GKE cluster Definition
resource "google_container_cluster" "todoapp" {
    name               = "thebesttodo"
    project            = var.project_id
    location           = var.zone
    initial_node_count = var.gke_workers_count

    addons_config {
        network_policy_config {
            disabled = true
        }
    }

    # Definition of Cluster Nodes
    node_config {
        # Check machine types for Kubernetes Nodes in https://cloud.google.com/compute/docs/general-purpose-machines
        # n1-standard-8  has 8xvCPU,   30 GB Memory  ->   62.49 $
        # n1-standard-4  has 4xvCPU,   15 GB Memory  ->   31.24 $
        # n1-standard-2  has 2xvCPU,  7.5 GB Memory  ->   15.62 $
        # e2-standard-32 has 32xvCPU, 128 GB Memory  ->  107.41 $
        # e2-standard-16 has 16xvCPU,  64 GB Memory  ->   53.71 $
        # e2-standard-8  has 8xvCPU,   32 GB Memory  ->   26.86 $
        # e2-standard-4  has 4xvCPU,   16 GB Memory  ->   13.43 $
        # e2-standard-2  has 2xvCPU,    8 GB Memory  ->    6.71 $
        # e2-medium      has 2xvCPU,    4 GB Memory  ->    3.36 $
        # e2-small       has 2xvCPU,    2 GB Memory  ->    1.68 $
        # e2-micro       has 2xvCPU,    1 GB Memory  ->    0.84 $
        machine_type = var.gke_node_machine_type

        # SPOTTING
        spot = true

        # The OAuth 2.0 scopes requested to access Google APIs,
        # depending on the level of access needed
        # Check Scopes in https://developers.google.com/identity/protocols/oauth2/scopes
        oauth_scopes = [
            "https://www.googleapis.com/auth/devstorage.read_only",
            "https://www.googleapis.com/auth/logging.write",
            "https://www.googleapis.com/auth/monitoring",
            "https://www.googleapis.com/auth/service.management.readonly",
            "https://www.googleapis.com/auth/servicecontrol",
            "https://www.googleapis.com/auth/trace.append",
            "https://www.googleapis.com/auth/compute",
        ]
    }

    # Set deletion_protection to false to allow cluster deletion
    deletion_protection = false
}
