resource "kubernetes_deployment" "finnhubproducer" {
  metadata {
    name = "finnhubproducer"
    namespace = "${var.namespace}"
    labels = {
      "k8s.service" = "finnhubproducer"
    }
  }

  depends_on = [
      "kubernetes_deployment.kafka_service",
      "kubernetes_deployment.cassandra"
  ]

  spec {
    replicas = 1

    selector {
      match_labels = {
        "k8s.service" = "finnhubproducer"
      }
    }

    template {
      metadata {
        labels = {
          "k8s.network/pipeline-network" = "true"

          "k8s.service" = "finnhubproducer"
        }
      }

      spec {
        container {
          name  = "finnhubproducer"
          image = "docker.io/library/finnhub-streaming-data-pipeline-finnhubproducer:latest"

          env_from {
            config_map_ref {
              name = "pipeline-config"
            }
          }

          env_from {
            secret_ref {
              name = "pipeline-secrets"
            }
          }

          image_pull_policy = "Never"
        }

        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "finnhubproducer" {
  metadata {
    name  = "finnhubproducer"
    namespace = "${var.namespace}"
    labels = {
      "k8s.service" = "finnhubproducer"
    }
  }

  depends_on = [
        "kubernetes_deployment.finnhubproducer"
  ]
  
  spec {
    port {
      name        = "8001"
      port        = 8001
      target_port = "8001"
    }

    selector = {
      "k8s.service" = "finnhubproducer"
    }

    cluster_ip = "None"
  }
}
