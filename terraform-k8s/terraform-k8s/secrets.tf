resource "kubernetes_secret" "secrets" {
  metadata {
    name = "secrets"
  }

  string_datum {}

  type = "Opaque"
}