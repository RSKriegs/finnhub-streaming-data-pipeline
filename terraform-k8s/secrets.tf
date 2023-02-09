resource "kubectl_manifest" "secrets" {
    yaml_body = <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: secrets
type: Opaque
stringData:
  FINNHUB_API_TOKEN: "" #insert token here
  CASSANDRA_USER: "" #insert user here
  CASSANDRA_PASSWORD: "" #insert password here 
  #IMPORTANT! while specifying custom password for Cassandra - remember to add password into grafana/dashboards/dashboard.json
  #file if you want to use custom one (or something else). https://community.grafana.com/t/dashboard-provisioning-with-variables/45516/9
YAML
}