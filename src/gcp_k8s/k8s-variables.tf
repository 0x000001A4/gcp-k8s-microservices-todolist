# Terraform google cloud multi tier Kubernetes deployment
# AGISIT Lab Cloud-Native Application in a Kubernetes Cluster

# Project id
variable "project_id" {}

# Other variables
variable "duckdns_token" {}
variable "duckdns_domain" {}

variable "docker_images" {}

variable "todoapp_namespace" {
    type = string
    description = "Name of the namespace to create for the todo app"
    default = "thebesttodoapp"

    nullable = false
    sensitive = false

    validation {
        condition = can(regex("^[a-z0-9-]+$", var.todoapp_namespace))
        error_message = "Namespace name must be alphanumeric (with some '-')"
    }
}

variable "todoapp_services" {
    type = map(object({
        endpoint       = string
        service-port   = number
        container-port = number
        replicas       = number
    }))
    description = "List of todo app services names"

    nullable = false
    sensitive = false

    validation {
        condition = alltrue([
            for k, v in var.todoapp_services :
                can(regex("^[a-z0-9-]+$", k)) &&
                can(regex("^/[a-zA-Z-*/]*$", v.endpoint)) &&
                v.service-port >= 0 && v.service-port <= 65535 &&
                v.container-port >= 0 && v.container-port <= 65535 &&
                v.replicas > 0
        ])
        error_message = "Todo App services must be alphanumeric (with some '-'). Port must be between 0 and 65535. Replicas must be greater than 0"
    }
}

##############
#   LOCALS   #
##############

locals {
    duckdns_full_domain = "${var.duckdns_domain}.duckdns.org"
}