# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

################################
##     Provider Variables     ##
################################

variable "project_id" {
    type = string
    description = "Project ID"

    nullable = false
    sensitive = false

    validation {
        condition = var.project_id != "" # Dummy condition, since idk what to put here and don't want to remove it :D
        error_message = "Project ID cannot be empty"
    }
}

variable "region" {
    type = string
    description = "Region"
    default = "us-west4"

    nullable = false
    sensitive = false

    validation {
        condition = can(regex("^[a-z]+-[a-z]+[0-9]+$", var.region))
        error_message = "Region must be in the format of <region>-<zone>-<number>"
    }
}

variable "subregion" {
    type = string
    description = "Subregion (single letter)"
    default = "a"

    nullable = false
    sensitive = false

    validation {
        condition = can(regex("^[a-z]$", var.subregion))
        error_message = "Subregion must be a single letter"
    }
}


################################
##           DOCKER           ##
################################

variable "docker_repo_name" {
    type = string
    description = "Name of the repository to create in Artifact Registry"
    default = "the-best-todo"

    validation {
        condition = can(regex("^[a-z0-9-]+$", var.docker_repo_name))
        error_message = "Repository name must be alphanumeric (with some '-')"
    }
}

################################
##            GKE             ##
################################

variable "gke_node_machine_type" {
    type = string
    description = "gke node machine type"
    default = "e2-standard-2"

    nullable = false
    sensitive = false

    validation {
        condition = can(regex("^[a-z0-9-]+$", var.gke_node_machine_type))
        error_message = "Machine type must be alphanumeric (with some '-')"
    }
}

variable "gke_workers_count" {
    type = number
    description = "gke workers count"
    default = 3

    nullable = false
    sensitive = false

    validation {
        condition = var.gke_workers_count > 0
        error_message = "Workers count must be greater than 0"
    }
}


################################
##             K8S            ##
################################

variable "k8s_todoapp_namespace" {
    type = string
    description = "Name of the namespace to create for the todo app"
    default = "thebesttodoapp"

    nullable = false
    sensitive = false

    validation {
        condition = can(regex("^[a-z0-9-]+$", var.k8s_todoapp_namespace))
        error_message = "Namespace name must be alphanumeric (with some '-')"
    }
}

variable "k8s_todoapp_services" {
    type = map(object({
        endpoint       = string
        service-port   = number
        container-port = number
        replicas       = number
    }))
    description = "List of todo app services names"
    default = {
        frontend = {
            endpoint       = "/*",
            service-port   = 5000,
            container-port = 5000,
            replicas       = 3,
        },
        taskadder = {
            endpoint       = "/api/addTask",
            service-port   = 5000,
            container-port = 5000,
            replicas       = 1,
        },
        taskeditor = {
            endpoint       = "/api/editTask",
            service-port   = 5000,
            container-port = 5000,
            replicas       = 1,
        },
        taskreader = {
            endpoint       = "/api/tasks",
            service-port   = 5000,
            container-port = 5000,
            replicas       = 1,
        },
        taskremover = {
            endpoint       = "/api/removeTask",
            service-port   = 5000,
            container-port = 5000,
            replicas       = 1,
        },
    }

    nullable = false
    sensitive = false

    validation {
        condition = alltrue([
            for k, v in var.k8s_todoapp_services :
                can(regex("^[a-z0-9-]+$", k)) &&
                can(regex("^/[a-zA-Z-*/]*$", v.endpoint)) &&
                v.service-port >= 0 && v.service-port <= 65535 &&
                v.container-port >= 0 && v.container-port <= 65535 &&
                v.replicas > 0
        ])
        error_message = "Todo App services must be alphanumeric (with some '-'). Port must be between 0 and 65535. Replicas must be greater than 0"
    }
}

################################
##           Others           ##
################################

variable "credentials_file" {
    type = string
    description = "Path to the service account key file"

    nullable = false
    sensitive = false

    validation {
        condition = can(fileexists(var.credentials_file))
        error_message = "Credentials file must exist!"
    }
}

variable "duckdns_token" {
    type = string
    description = "DuckDNS token"

    nullable = false
    sensitive = true

    validation {
        condition = var.duckdns_token != ""
        error_message = "DuckDNS token cannot be empty"
    }
}

variable "duckdns_domain" {
    type = string
    description = "DuckDNS domain"
    default = "cocozinho"

    nullable = false
    sensitive = false

    validation {
        condition = can(regex("^[a-z0-9-]+$", var.duckdns_domain))
        error_message = "DuckDNS domain must be alphanumeric (with some '-')"
    }
}


################################
##           Locals           ##
################################

locals {
    # Join the region and subregion together to form the zone
    zone = "${var.region}-${var.subregion}"
}