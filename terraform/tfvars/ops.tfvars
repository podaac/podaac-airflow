# Airflow image = main as it's the constantly built version
airflow_docker_images = {
  "airflow": {
    "name": "ghcr.io/podaac/podaac-airflow",
    "tag": "main"
  }
}

airflow_webserver_username = "admin"

deployment_name = ""
helm_charts = {
  "airflow": {
    "chart": "airflow",
    "repository": "https://airflow.apache.org",
    "version": "1.15.0"
  },
  "keda": {
    "chart": "keda",
    "repository": "https://kedacore.github.io/charts",
    "version": "v2.15.1"
  }
}

installprefix = ""

kubeconfig_filepath = "/home/runner/.kube/config"

ogc_processes_docker_images = {
  "git_sync": {
    "name": "registry.k8s.io/git-sync/git-sync",
    "tag": "v4.2.4"
  },
  "ogc_processes_api": {
    "name": "ghcr.io/unity-sds/unity-sps-ogc-processes-api/unity-sps-ogc-processes-api",
    "tag": "2.0.0"
  },
  "redis": {
    "name": "redis",
    "tag": "7.4.0"
  }
}

project = "podaac-services"
venue   = "ops"
release      = "24.4"
service_area = "airflow"
tags = {
  "empty": ""
}

ami_image_id = "ami-064627abd5267ac59"

# this should match what you did the `terraform init backend=` step with
airflow_state_bucket = "podaac-ops-services-airflow"
