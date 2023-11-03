# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud-Native Application in a Kubernetes Cluster

# ISTIO Service Mesh deployment via Helm Charts
resource "helm_release" "istio_base" {
    depends_on = [
        kubernetes_namespace_v1.istio_system
    ]

    name       = "istio-base"
    chart      = "base"
    repository = "https://istio-release.storage.googleapis.com/charts"
    version    = "1.14.3"

    timeout    = 120

    cleanup_on_fail = true
    force_update    = true
    namespace       = kubernetes_namespace_v1.istio_system.metadata[0].name
}

resource "helm_release" "istiod" {
    depends_on = [
        helm_release.istio_base
    ]

    name       = "istiod"
    chart      = "istiod"
    repository = helm_release.istio_base.repository
    version    = helm_release.istio_base.version

    timeout    = 120

    cleanup_on_fail = true
    force_update    = true
    namespace       = kubernetes_namespace_v1.istio_system.metadata[0].name
}