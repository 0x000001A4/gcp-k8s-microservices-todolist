variable "region" {}
variable "project_id" {}

variable "repo_name" {
    type = string
    description = "Name of the repository to create in Artifact Registry"
    default = "the-best-todo"

    validation {
        condition = can(regex("^[a-z0-9-]+$", var.repo_name))
        error_message = "Repository name must be alphanumeric (with some '-')"
    }
}

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
    gcp_artifact_registry_host       = "${var.region}-docker.pkg.dev"
    gcp_artifact_registry_repository = "${local.gcp_artifact_registry_host}/${var.project_id}/${var.repo_name}"
}