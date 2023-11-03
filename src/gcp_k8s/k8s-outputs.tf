output "ingress" {
    value = {
        domain  = kubernetes_ingress_v1.reverse_proxy.spec[0].rule[0].host
        address = kubernetes_ingress_v1.reverse_proxy.status[0].load_balancer[0].ingress[0].ip
    }
    sensitive = false
}