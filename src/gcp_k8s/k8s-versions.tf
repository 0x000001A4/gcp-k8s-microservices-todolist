# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
    required_providers {
        helm = {
            source = "hashicorp/helm"
        }

        kubectl = {
            source = "gavinbunney/kubectl"
        }

        kubernetes = {
            source = "hashicorp/kubernetes"
        }

        null = {
            source = "hashicorp/null"
            version = "~> 3.2.1"
        }
    }

    required_version = ">= 1.5.7"
}