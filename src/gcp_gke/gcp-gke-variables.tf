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

variable "zone" {
    type = string
    description = "Zone"
    default = "us-west4-a"

    nullable = false
    sensitive = false

    validation {
        condition = can(regex("^[a-z]+-[a-z]+[0-9]+-[a-z]+$", var.zone))
        error_message = "Zone must be in the format of <region>-<zone>-<number>-<subregion>"
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
