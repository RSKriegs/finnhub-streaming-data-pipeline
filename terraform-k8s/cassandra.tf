resource "kubernetes_persistent_volume" "cassandra-db-volume" {
  metadata {
    name = "cassandra-db-volume"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteMany"]
    storage_class_name = "hostpath"
    persistent_volume_source {
      host_path {
        path = "/data/pv0001/"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "cassandra_db-volume" {
  metadata {
    name = "cassandra-db-volume"
    namespace = "${var.namespace}"
    labels = {
      "k8s.service" = "cassandra-db-volume"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    storage_class_name = "hostpath"

    resources {
      requests = {
        storage = "5Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "cassandra" {
  metadata {
    name = "cassandra"
    namespace = "${var.namespace}"
    labels = {
      "k8s.service" = "cassandra"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "k8s.service" = "cassandra"
      }
    }

    template {
      metadata {
        labels = {
          "k8s.network/pipeline-network" = "true"

          "k8s.service" = "cassandra"
        }
      }

      spec {
        volume {
          name = "cassandra-data"

          persistent_volume_claim {
            claim_name = "cassandra-db-volume"
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
                name = "pipeline-secrets"
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
                name = "pipeline-secrets"
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
      }
    }
  }
}

resource "kubernetes_service" "cassandra" {
  metadata {
    name = "cassandra"
    namespace = "${var.namespace}"
    labels = {
      "k8s.service" = "cassandra"
    }
  }

  spec {
    port {
      name        = "9042"
      port        = 9042
      target_port = "9042"
    }

    selector = {
      "k8s.service" = "cassandra"
    }

    cluster_ip = "None"
  }
}