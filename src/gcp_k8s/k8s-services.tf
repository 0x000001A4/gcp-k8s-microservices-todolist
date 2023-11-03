# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud-Native Application in a Kubernetes Cluster

#################################################################
# Definition of the Services
#################################################################

###############################
##         DataBase          ##
###############################

# The Service for the REDIS Leader Pods
resource "kubernetes_service" "redis-leader" {
    metadata {
        name = "redis-leader"

        labels = {
            app  = "redis"
            role = "leader"
            tier = "backend"
        }

        namespace = kubernetes_namespace_v1.todoapp.id
    }

    spec {
        selector = {
            app  = "redis"
            role = "leader"
            tier = "backend"
        }

        port {
            port        = 6379
            target_port = 6379
        }
    }
}
# The Service for the REDIS Follower Pods
resource "kubernetes_service" "redis-follower" {
    metadata {
        name = "redis-follower"

        labels = {
            app  = "redis"
            role = "follower"
            tier = "backend"
        }

        namespace = kubernetes_namespace_v1.todoapp.id
    }

    spec {
        selector = {
            app  = "redis"
            role = "follower"
            tier = "backend"
        }

        port {
            port        = 6379
        }
    }
}



###############################
##         TODO APP          ##
###############################

resource "kubernetes_service_v1" "todoapp" {
    for_each = var.todoapp_services

    depends_on = [
        kubernetes_deployment_v1.todoapp
    ]

    metadata {
        name = "${each.key}-service"
        annotations = {
            "cloud.google.com/app-protocols" = "{\"https-port\":\"HTTPS\"}"
        }
        namespace = kubernetes_namespace_v1.todoapp.id
    }

    spec {
        type = "NodePort"

        selector = {
            app = kubernetes_deployment_v1.todoapp[each.key].metadata[0].labels.app
        }

        port {
            name        = "https-port"
            protocol    = "TCP"
            port        = each.value.service-port
            target_port = kubernetes_deployment_v1.todoapp[each.key].spec[0].template[0].spec[0].container[0].port[0].container_port
        }
    }
}