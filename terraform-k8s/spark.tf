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

  set {
    name  = "webhook.enable"
    value = true
  }
}

resource "kubernetes_manifest" "service_account" {
  depends_on = [
      "kubernetes_namespace.pipeline-namespace"
  ]

  manifest = {
    "apiVersion" = "v1"
    "kind"       = "ServiceAccount"
    "metadata" = {
      "name"      = "spark"
      "namespace" = "${var.namespace}"
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
    namespace = "${var.namespace}"
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "meta.helm.sh/release-name" = "spark-on-k8s"
      "meta.helm.sh/release-namespace" = "spark-operator"
    }
  }

  depends_on = [
      "kubernetes_namespace.pipeline-namespace"
  ]
  
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
    namespace = "${var.namespace}"
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "meta.helm.sh/release-name" = "spark-on-k8s"
      "meta.helm.sh/release-namespace" = "spark-operator"
    }
  }
  depends_on = [
      "kubernetes_namespace.pipeline-namespace"
  ]
  

  subject {
    kind      = "ServiceAccount"
    name      = "spark"
    namespace = pathexpand(var.namespace)
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "spark-role"
  }
}

