# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "~> 5.1.0"
        }

        helm = {
            source = "hashicorp/helm"
            version = "~> 2.11.0"
        }

        kubectl = {
            source = "gavinbunney/kubectl"
            version = "~> 1.14.0"
        }

        kubernetes = {
            source = "hashicorp/kubernetes"
            version = "~> 2.23.0"
        }
    }

    required_version = ">= 1.5.7"
}