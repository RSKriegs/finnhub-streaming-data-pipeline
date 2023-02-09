resource "kubernetes_deployment" "kafka_service" {
  metadata {
    name = "kafka-service"

    labels = {
      "io.kompose.service" = "kafka-service"
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
        "io.kompose.service" = "kafka-service"
      }
    }

    template {
      metadata {
        labels = {
          "io.kompose.network/pipeline-network" = "true"

          "io.kompose.service" = "kafka-service"
        }

        annotations = {
          "kompose.cmd" = "C:\\ProgramData\\chocolatey\\lib\\kubernetes-kompose\\tools\\kompose.exe convert"

          "kompose.version" = "1.27.0 (b0ed6a2c9)"
        }
      }

      spec {
        container {
          name  = "kafka-service"
          image = "finnhub-streaming-data-pipeline-kafka:latest"

          port {
            container_port = 9092
          }

          port {
            container_port = 29092
          }

          env {
            name  = "KAFKA_LISTENERS"
            value = "PLAINTEXT://0.0.0.0:29092,PLAINTEXT_HOST://0.0.0.0:9092"
          }

          env {
            name  = "KAFKA_ADVERTISED_LISTENERS"
            value = "PLAINTEXT://localhost:29092,PLAINTEXT_HOST://kafka-service.default.svc.cluster.local:9092"
          }

          env {
            name  = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
            value = "PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT"
          }

          env {
            name  = "KAFKA_INTER_BROKER_LISTENER_NAME"
            value = "PLAINTEXT"
          }

          env {
            name  = "KAFKA_BROKER_ID"
            value = "1"
          }

          env {
            name  = "KAFKA_CONFLUENT_BALANCER_TOPIC_REPLICATION_FACTOR"
            value = "1"
          }

          env {
            name  = "KAFKA_CONFLUENT_LICENSE_TOPIC_REPLICATION_FACTOR"
            value = "1"
          }

          env {
            name  = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS"
            value = "0"
          }

          env {
            name  = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR"
            value = "1"
          }

          env {
            name  = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR"
            value = "1"
          }

          env {
            name  = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR"
            value = "1"
          }

          env {
            name  = "KAFKA_ZOOKEEPER_CONNECT"
            value = "zookeeper:2181"
          }

          lifecycle {
            post_start {
              exec {
                command = ["/bin/sh", "-c", "kafka-topics --bootstrap-server localhost:29092 --create --if-not-exists --topic market --replication-factor 1 --partitions 1"]
              }
            }
          }

          image_pull_policy = "Never"
        }

        container {
          name  = "kafdrop"
          image = "obsidiandynamics/kafdrop:3.27.0"

          port {
            container_port = 9000
          }

          env {
            name  = "KAFKA_BROKERCONNECT"
            value = "localhost:29092"
          }
        }

        restart_policy = "Always"
        hostname       = "kafka-service"
      }
    }
  }
}

resource "kubernetes_deployment" "zookeeper" {
  metadata {
    name = "zookeeper"

    labels = {
      "io.kompose.service" = "zookeeper"
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
        "io.kompose.service" = "zookeeper"
      }
    }

    template {
      metadata {
        labels = {
          "io.kompose.network/pipeline-network" = "true"

          "io.kompose.service" = "zookeeper"
        }

        annotations = {
          "kompose.cmd" = "C:\\ProgramData\\chocolatey\\lib\\kubernetes-kompose\\tools\\kompose.exe convert"

          "kompose.version" = "1.27.0 (b0ed6a2c9)"
        }
      }

      spec {
        container {
          name  = "zookeeper"
          image = "confluentinc/cp-zookeeper:6.2.0"

          port {
            container_port = 2181
          }

          env {
            name  = "ZOOKEEPER_CLIENT_PORT"
            value = "2181"
          }

          env {
            name  = "ZOOKEEPER_TICK_TIME"
            value = "2000"
          }
        }

        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "kafka_service" {
  metadata {
    name = "kafka-service"

    labels = {
      "io.kompose.service" = "kafka-service"
    }

    annotations = {
      "kompose.cmd" = "C:\\ProgramData\\chocolatey\\lib\\kubernetes-kompose\\tools\\kompose.exe convert"

      "kompose.version" = "1.27.0 (b0ed6a2c9)"
    }
  }

  spec {
    port {
      name        = "9092"
      port        = 9092
      target_port = "9092"
    }

    port {
      name        = "29092"
      port        = 29092
      target_port = "29092"
    }

    port {
      name        = "19000"
      port        = 19000
      target_port = "9000"
    }

    selector = {
      "io.kompose.service" = "kafka-service"
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_service" "zookeeper" {
  metadata {
    name = "zookeeper"

    labels = {
      "io.kompose.service" = "zookeeper"
    }

    annotations = {
      "kompose.cmd" = "C:\\ProgramData\\chocolatey\\lib\\kubernetes-kompose\\tools\\kompose.exe convert"

      "kompose.version" = "1.27.0 (b0ed6a2c9)"
    }
  }

  spec {
    port {
      name        = "2181"
      port        = 2181
      target_port = "2181"
    }

    selector = {
      "io.kompose.service" = "zookeeper"
    }

    cluster_ip = "None"
  }
}
