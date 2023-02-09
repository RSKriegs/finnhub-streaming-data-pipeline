resource "kubernetes_deployment" "grafana" {
  metadata {
    name = "grafana"

    labels = {
      "io.kompose.service" = "grafana"
    }

    annotations = {
      "kompose.cmd" = "C:\\ProgramData\\chocolatey\\lib\\kubernetes-kompose\\tools\\kompose.exe convert"

      "kompose.version" = "1.27.0 (b0ed6a2c9)"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "io.kompose.service" = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          "io.kompose.network/pipeline-network" = "true"

          "io.kompose.service" = "grafana"
        }

        annotations = {
          "kompose.cmd" = "C:\\ProgramData\\chocolatey\\lib\\kubernetes-kompose\\tools\\kompose.exe convert"

          "kompose.version" = "1.27.0 (b0ed6a2c9)"
        }
      }

      spec {
        container {
          name  = "grafana"
          image = "docker.io/library/finnhub-streaming-data-pipeline-grafana:latest"

          port {
            container_port = 3000
          }

          env {
            name  = "GF_AUTH_ANONYMOUS_ENABLED"
            value = "true"
          }

          env {
            name  = "GF_DASHBOARDS_DEFAULT_HOME_DASHBOARD_PATH"
            value = "/var/lib/grafana/dashboards/dashboard.json"
          }

          image_pull_policy = "Never"
        }

        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name = "grafana"

    labels = {
      "io.kompose.service" = "grafana"
    }

    annotations = {
      "kompose.cmd" = "C:\\ProgramData\\chocolatey\\lib\\kubernetes-kompose\\tools\\kompose.exe convert"

      "kompose.version" = "1.27.0 (b0ed6a2c9)"
    }
  }

  spec {
    port {
      name        = "3000"
      port        = 3000
      target_port = "3000"
      node_port   = 30001
    }

    selector = {
      "io.kompose.service" = "grafana"
    }

    type = "NodePort"
  }
}
