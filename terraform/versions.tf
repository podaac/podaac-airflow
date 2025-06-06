terraform {
  required_version = "~> 1.8"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.4"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.67.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
  }
}
