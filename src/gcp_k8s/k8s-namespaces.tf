# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud-Native Application in a Kubernetes Cluster

resource "kubernetes_namespace_v1" "istio_system" {
    metadata {
        name = "istio-system"
    }
}

resource "kubernetes_namespace_v1" "todoapp" {
    metadata {
        name = var.todoapp_namespace

        labels = {
            istio-injection = "enabled"
        }
    }
}