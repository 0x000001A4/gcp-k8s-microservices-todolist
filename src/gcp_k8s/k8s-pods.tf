# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud-Native Application in a Kubernetes Cluster

#################################################################
# Definition of the Pods
#################################################################

# The Backend Pods for Data Store deployment with REDIS
# Defines 1 Leader (not replicated)
# Defines 2 Followers (replicated) 
# see: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/replication_controller

# Defines 1 REDIS Leader (not replicated)
resource "kubernetes_deployment_v1" "redis-leader" {
    depends_on = [
        helm_release.istiod,
        kubernetes_namespace_v1.todoapp
    ]

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
        progress_deadline_seconds = 1800 # In case of taking longer than 30 minutes
        replicas = 1
        selector {
            match_labels = {
                app  = "redis"
            }
        }
        template {
            metadata {
                labels = {
                    app  = "redis"
                    role = "leader"
                    tier = "backend"
                }
            }
            spec {
                container {
                    image = "docker.io/redis:6.0.5"
                    name  = "leader"

                    port {
                        container_port = 6379
                    }

                    resources {
                        requests = {
                            cpu    = "100m"
                            memory = "100Mi"
                        }
                    }
                }
            }
        }
    }
}
# Defines 2 REDIS Follower (replicated)
resource "kubernetes_deployment_v1" "redis-follower" {
    depends_on = [
        helm_release.istiod,
        kubernetes_namespace_v1.todoapp
    ]

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
        progress_deadline_seconds = 1800 # In case of taking longer than 30 minutes
        replicas = 2
        selector {
            match_labels = {
                app  = "redis"
            }
        }
        template {
            metadata {
                labels = {
                    app  = "redis"
                    role = "follower"
                    tier = "backend"
                }
            }
            spec {
                container {
                    image = "gcr.io/google_samples/gb-redis-follower:v2"
                    name  = "follower"

                    port {
                        container_port = 6379
                    }

                    env {
                        name  = "GET_HOSTS_FROM"
                        value = "dns"
                    }

                    resources {
                        requests = {
                            cpu    = "100m"
                            memory = "100Mi"
                        }
                    }
                }
            }
        }
    }
}



#################################################################
# Define the Pods for the Todo App
resource "kubernetes_deployment_v1" "todoapp" {
    depends_on = [
        helm_release.istiod,
        kubernetes_namespace_v1.todoapp
    ]

    for_each = var.todoapp_services

    timeouts {
        create = "15m"
        update = "10m"
    }

    metadata {
        name = "${each.key}-deployment"

        labels = {
            app  = "flask-${each.key}"
        }

        namespace = kubernetes_namespace_v1.todoapp.id
    }

    spec {
        progress_deadline_seconds = 1800 # In case of taking longer than 30 minutes

        replicas = each.value.replicas
        selector {
            match_labels = {
                app  = "flask-${each.key}"
            }
        }

        template {
            metadata {
                labels = {
                    app  = "flask-${each.key}"
                }
            }
            spec {
                # THE IMAGE NEEDS TO ALREADY EXIST
                # just run docker_build_push.sh
                container {
                    name  = "flask-${each.key}-docker"
                    image = var.docker_images[each.key].name
                    image_pull_policy = "Always"

                    port {
                        container_port = each.value.container-port
                    }
                }
            }
        }
    }
}
