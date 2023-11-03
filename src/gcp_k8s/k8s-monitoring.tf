# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud-Native Application in a Kubernetes Cluster

# Prometheus deployment (Required for using multiple files in kubectl_manifest)
data "kubectl_file_documents" "prometheus_docs" {
    content = file("${path.module}/monitoring/prometheus.yaml")
}

# kubectl_manifest allows you to use kubernetes resources as terraform resources
# Same as using kubectl apply command
resource "kubectl_manifest" "prometheus" {
    for_each  = data.kubectl_file_documents.prometheus_docs.manifests
    yaml_body = each.value

    depends_on = [
        kubernetes_namespace_v1.istio_system
    ]
}

# Grafana deployment (Required for using multiple files in kubectl_manifest)
data "kubectl_file_documents" "grafana_docs" {
    content = file("${path.module}/monitoring/grafana.yaml")
}

# kubectl_manifest allows you to use kubernetes resources as terraform resources
# Same as using kubectl apply command
resource "kubectl_manifest" "grafana" {
    for_each  = data.kubectl_file_documents.grafana_docs.manifests
    yaml_body = each.value

    depends_on = [
        kubernetes_namespace_v1.istio_system
    ]
}