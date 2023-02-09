terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.8.0"
    }
  }
}

provider "kubernetes" {
  config_path    = pathexpand(var.kube_config)
  config_context = "minikube"
}

provider "helm" {
  kubernetes {
    config_path = pathexpand(var.kube_config)
  }
}