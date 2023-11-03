#################################################################
# Create the TLS secret for the ingress
resource "kubernetes_secret_v1" "tls" {
    metadata {
        name      = "the-best-todo-tls"
        namespace = kubernetes_namespace_v1.todoapp.id
    }

    type = "kubernetes.io/tls"

    binary_data = {
        "tls.crt" = filebase64("${path.cwd}/containers/keys/cert.pem")
        "tls.key" = filebase64("${path.cwd}/containers/keys/privkey.pem")
    }
}


#################################################################
# Define the Ingress Rules for the todoapp
resource "kubernetes_ingress_v1" "reverse_proxy" {
    depends_on = [ 
        # google_compute_global_address.ipbuedebom,
        # kubernetes_service_v1.todoapp,
        # kubernetes_secret_v1.tls
    ]

    wait_for_load_balancer = true
    timeouts {
        create = "8m"
        delete = "8m"
    }

    metadata {
        name = "the-best-todo-ingress"
        annotations = {
            "spec.ingressClassName": "gce",
            "kubernetes.io/ingress.allow-http" = "false"
        }
        namespace = kubernetes_namespace_v1.todoapp.id
    }

    spec {
        tls {
            hosts = [
                local.duckdns_full_domain
            ]
            secret_name = kubernetes_secret_v1.tls.metadata[0].name
        }

        rule {
            host = local.duckdns_full_domain
            http {
                dynamic "path" {
                    for_each = var.todoapp_services

                    content {
                        path = path.value.endpoint
                        path_type = "ImplementationSpecific"

                        backend {
                            service {
                                name = kubernetes_service_v1.todoapp[path.key].metadata[0].name
                                port {
                                    number = kubernetes_service_v1.todoapp[path.key].spec[0].port[0].port
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


# Update the IP in DuckDNS
resource "null_resource" "update_duckdns" {
    # This triggers the provisioner to run when the static IP changes (it shouldn't xd)
    # it also triggers with domain/token change, cuz I'm forced to do that to be able to use them in the provisioner xd ty terraform for being so good
    triggers = {
        ingress_ip = kubernetes_ingress_v1.reverse_proxy.status[0].load_balancer[0].ingress[0].ip
        domain     = var.duckdns_domain
        token      = var.duckdns_token
    }

    # Update the IP in DuckDNS
    provisioner "local-exec" {
        command     = "https://www.duckdns.org/update?domains=${self.triggers.domain}&token=${self.triggers.token}&ip=${self.triggers.ingress_ip}"
        quiet       = true
        when        = create
        interpreter = [ "curl", "-s" ]
    }

    # Reset the IP in DuckDNS (set to 127.0.0.1)
    provisioner "local-exec" {
        command     = "https://www.duckdns.org/update?domains=${self.triggers.domain}&token=${self.triggers.token}&ip=127.0.0.1"
        quiet       = true
        when        = destroy
        interpreter = [ "curl", "-s" ]
    }
}
