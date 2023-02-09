resource "kubernetes_deployment" "finnhubproducer" {
  metadata {
    name = "finnhubproducer"

    labels = {
      "io.kompose.service" = "finnhubproducer"
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
        "io.kompose.service" = "finnhubproducer"
      }
    }

    template {
      metadata {
        labels = {
          "io.kompose.network/pipeline-network" = "true"

          "io.kompose.service" = "finnhubproducer"
        }

        annotations = {
          "kompose.cmd" = "C:\\ProgramData\\chocolatey\\lib\\kubernetes-kompose\\tools\\kompose.exe convert"

          "kompose.version" = "1.27.0 (b0ed6a2c9)"
        }
      }

      spec {
        container {
          name  = "finnhubproducer"
          image = "docker.io/library/finnhub-streaming-data-pipeline-finnhubproducer:latest"

          port {
            container_port = 8001
          }

          env {
            name  = "KAFKA_PORT"
            value = "9092"
          }

          env {
            name  = "KAFKA_SERVER"
            value = "kafka-service.default.svc.cluster.local"
          }

          env {
            name  = "KAFKA_TOPIC_NAME"
            value = "market"
          }

          env {
            name = "FINNHUB_API_TOKEN"

            value_from {
              secret_key_ref {
                name = "secrets"
                key  = "FINNHUB_API_TOKEN"
              }
            }
          }

          env {
            name  = "FINNHUB_STOCKS_TICKERS"
            value = "BINANCE:BTCUSDT,BINANCE:ETHUSDT,BINANCE:XRPUSDT,BINANCE:DOGEUSDT"
          }

          env {
            name  = "FINNHUB_VALIDATE_TICKERS"
            value = "1"
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
    name = "finnhubproducer"

    labels = {
      "io.kompose.service" = "finnhubproducer"
    }

    annotations = {
      "kompose.cmd" = "C:\\ProgramData\\chocolatey\\lib\\kubernetes-kompose\\tools\\kompose.exe convert"

      "kompose.version" = "1.27.0 (b0ed6a2c9)"
    }
  }

  spec {
    port {
      name        = "8001"
      port        = 8001
      target_port = "8001"
    }

    selector = {
      "io.kompose.service" = "finnhubproducer"
    }

    cluster_ip = "None"
  }
}