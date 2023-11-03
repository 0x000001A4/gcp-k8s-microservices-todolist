# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
# Terraform google cloud multi tier Kubernetes deployment


#####################################################################
# Modules for Provisioning and Deployment
#####################################################################

module "gcp_docker" {
    source     = "./gcp_docker"
    project_id = var.project_id
    region     = var.region
    repo_name  = var.docker_repo_name

    todoapp_namespace = var.k8s_todoapp_namespace
    todoapp_services  = var.k8s_todoapp_services
}

# The module in folder 'gcp_gke' defines the Kubernetes Cluster
module "gcp_gke" {
    source     = "./gcp_gke"
    project_id = var.project_id
    zone       = local.zone

    gke_workers_count     = var.gke_workers_count
    gke_node_machine_type = var.gke_node_machine_type
}


# The module in folder 'gcp_k8s' defines the Pods and Services
module "gcp_k8s" {
    # For some reason this is breaking monitoring stuff lol
    # depends_on = [
    #     module.gcp_docker,
    #     module.gcp_gke
    # ]

    providers = {
        helm         = helm
        kubectl      = kubectl
        kubernetes   = kubernetes
    }

    source           = "./gcp_k8s"
    project_id       = var.project_id

    duckdns_token    = var.duckdns_token
    duckdns_domain   = var.duckdns_domain

    docker_images    = module.gcp_docker.docker_images

    todoapp_namespace = var.k8s_todoapp_namespace
    todoapp_services  = var.k8s_todoapp_services
}
