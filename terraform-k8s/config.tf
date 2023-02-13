resource "kubernetes_namespace" "pipeline-namespace" {
  metadata {
    name = "${var.namespace}"
  }
}

resource "kubernetes_config_map" "pipeline-config" {
  metadata {
    name      = "pipeline-config"
    namespace = "${var.namespace}"
  }

  data = {
    FINNHUB_STOCKS_TICKERS        = jsonencode(var.finnhub_stocks_tickers)
    FINNHUB_VALIDATE_TICKERS      = "1"
    
    KAFKA_SERVER                  = "kafka-service.${var.namespace}.svc.cluster.local"
    KAFKA_PORT                    = "9092"
    KAFKA_TOPIC_NAME              = "market"
    KAFKA_MIN_PARTITIONS          = "1"

    CASSANDRA_HOST                = "cassandra"
    
    SPARK_MASTER                  = "spark://spark-master:7077"
    SPARK_MAX_OFFSETS_PER_TRIGGER = "1000"
    SPARK_SHUFFLE_PARTITIONS      = "2"
    SPARK_DEPRECATED_OFFSETS      = "False"
  }
}

resource "kubernetes_secret" "pipeline-secrets" {
  metadata {
    name      = "pipeline-secrets"
    namespace = "${var.namespace}"
  }

  data = {
    #IMPORTANT! while specifying custom password for Cassandra - remember to add password into grafana/dashboards/dashboard.json
    #file if you want to use custom one (or something else). https://community.grafana.com/t/dashboard-provisioning-with-variables/45516/9
    FINNHUB_API_TOKEN             = "" #insert token here
    CASSANDRA_USER                = "" #insert user here
    CASSANDRA_PASSWORD            = "" #insert password here
  }

  type = "opaque"
}

resource "kubernetes_network_policy" "pipeline_network" {
  metadata {
    name = "pipeline-network"
    namespace = "${var.namespace}"
  }

  spec {
    pod_selector {
      match_labels = {
        "k8s.network/pipeline-network" = "true"
      }
    }

    policy_types = ["Ingress"]

    ingress {
      from {
        pod_selector {
          match_labels = {
            "k8s.network/pipeline-network" = "true"
          }
        }
      }
    }
  }
}