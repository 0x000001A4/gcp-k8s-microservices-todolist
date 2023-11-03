#####################################################################
# Output for K8S
#####################################################################

output "client_certificate" {
    value     = module.gcp_gke.client_certificate
    sensitive = true
}

output "client_key" {
    value     = module.gcp_gke.client_key
    sensitive = true
}

output "cluster_ca_certificate" {
    value     = module.gcp_gke.cluster_ca_certificate
    sensitive = true
}

output "host" {
    value     = module.gcp_gke.host
    sensitive = false
}

output "backend_services" {
    value     = var.k8s_todoapp_services
    sensitive = false
}

output "ingress" {
    value     = module.gcp_k8s.ingress
    sensitive = false
}
