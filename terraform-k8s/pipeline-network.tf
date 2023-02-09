resource "kubernetes_network_policy" "pipeline_network" {
  metadata {
    name = "pipeline-network"
  }

  spec {
    pod_selector {
      match_labels = {
        "io.kompose.network/pipeline-network" = "true"
      }
    }

    policy_types = ["Ingress"]

    ingress {
      from {
        pod_selector {
          match_labels = {
            "io.kompose.network/pipeline-network" = "true"
          }
        }
      }
    }
  }
}