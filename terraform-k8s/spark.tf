resource "helm_release" "spark-on-k8s" {
  name       = "spark-on-k8s"
  repository = "https://googlecloudplatform.github.io/spark-on-k8s-operator"
  chart      = "spark-operator"
  namespace  = "spark-operator"
  create_namespace = true

  set {
    name  = "sparkJobNamespace"
    value = pathexpand(var.namespace)
  }
}

resource "kubernetes_manifest" "service_account" {
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "name"      = "spark"
      "namespace" = "default"
      "labels" = {
        "app.kubernetes.io/managed-by" = "Helm"
      }
      "annotations" = {
        "meta.helm.sh/release-name" = "spark-on-k8s"
        "meta.helm.sh/release-namespace" = "spark-operator"
      }
    }
  }
}

resource "kubernetes_role" "spark_role" {
  metadata {
    name      = "spark-role"
    namespace = "default"
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "meta.helm.sh/release-name" = "spark-on-k8s"
      "meta.helm.sh/release-namespace" = "spark-operator"
    }
  }

  rule {
    verbs      = ["*"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["*"]
    api_groups = [""]
    resources  = ["services"]
  }
}

resource "kubernetes_role_binding" "spark_role_binding" {
  metadata {
    name      = "spark-role-binding"
    namespace = "default"
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "meta.helm.sh/release-name" = "spark-on-k8s"
      "meta.helm.sh/release-namespace" = "spark-operator"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "spark"
    namespace = "default"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "spark-role"
  }
}

