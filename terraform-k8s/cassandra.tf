resource "kubernetes_persistent_volume_claim" "cassandra_claim_0" {
  metadata {
    name = "cassandra-claim0"

    labels = {
      "io.kompose.service" = "cassandra-claim0"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "cassandra" {
  metadata {
    name = "cassandra"

    labels = {
      "io.kompose.service" = "cassandra"
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
        "io.kompose.service" = "cassandra"
      }
    }

    template {
      metadata {
        labels = {
          "io.kompose.network/pipeline-network" = "true"

          "io.kompose.service" = "cassandra"
        }

        annotations = {
          "kompose.cmd" = "C:\\ProgramData\\chocolatey\\lib\\kubernetes-kompose\\tools\\kompose.exe convert"

          "kompose.version" = "1.27.0 (b0ed6a2c9)"
        }
      }

      spec {
        volume {
          name = "cassandra-data"

          persistent_volume_claim {
            claim_name = "cassandra-claim0"
          }
        }

        container {
          name  = "cassandra"
          image = "finnhub-streaming-data-pipeline-cassandra:latest"

          port {
            container_port = 9042
          }

          env {
            name  = "CASSANDRA_CLUSTER_NAME"
            value = "CassandraCluster"
          }

          env {
            name  = "CASSANDRA_DATACENTER"
            value = "DataCenter1"
          }

          env {
            name  = "CASSANDRA_ENDPOINT_SNITCH"
            value = "GossipingPropertyFileSnitch"
          }

          env {
            name  = "CASSANDRA_HOST"
            value = "cassandra"
          }

          env {
            name  = "CASSANDRA_NUM_TOKENS"
            value = "128"
          }

          env {
            name = "CASSANDRA_PASSWORD"

            value_from {
              secret_key_ref {
                name = "secrets"
                key  = "CASSANDRA_PASSWORD"
              }
            }
          }

          env {
            name  = "CASSANDRA_RACK"
            value = "Rack1"
          }

          env {
            name = "CASSANDRA_USER"

            value_from {
              secret_key_ref {
                name = "secrets"
                key  = "CASSANDRA_USER"
              }
            }
          }

          env {
            name  = "HEAP_NEWSIZE"
            value = "128M"
          }

          env {
            name  = "MAX_HEAP_SIZE"
            value = "256M"
          }

          env {
            name = "POD_IP"

            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          volume_mount {
            name       = "cassandra-data"
            mount_path = "/var/lib/cassandra"
          }

          lifecycle {
            post_start {
              exec {
                command = ["/bin/sh", "-c", "sleep 45 && echo loading cassandra keyspace && cqlsh cassandra -u cassandra -p cassandra -f /cassandra-setup.cql"]
              }
            }
          }

          image_pull_policy = "Never"
        }

        hostname = "cassandra"
      }
    }
  }
}

resource "kubernetes_service" "cassandra" {
  metadata {
    name = "cassandra"

    labels = {
      "io.kompose.service" = "cassandra"
    }

    annotations = {
      "kompose.cmd" = "C:\\ProgramData\\chocolatey\\lib\\kubernetes-kompose\\tools\\kompose.exe convert"

      "kompose.version" = "1.27.0 (b0ed6a2c9)"
    }
  }

  spec {
    port {
      name        = "9042"
      port        = 9042
      target_port = "9042"
    }

    selector = {
      "io.kompose.service" = "cassandra"
    }

    cluster_ip = "None"
  }
}