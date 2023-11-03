provider "docker" {
    host = "unix:///var/run/docker.sock"

    registry_auth {
        address     = local.gcp_artifact_registry_host
        config_file_content = jsonencode({
                "credHelpers": {
                    "${local.gcp_artifact_registry_host}": "gcloud"
                }
            })
    }
}