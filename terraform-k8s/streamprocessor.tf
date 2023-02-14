//TODO: environment variables issue - spark driver fails to mount configMaps, fix the issue as follows: https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/issues/1619

resource "kubectl_manifest" "streamprocessor" {
  depends_on = [
      "kubernetes_deployment.kafka_service",
      "kubernetes_deployment.cassandra"
  ]
  yaml_body = <<YAML
apiVersion: "sparkoperator.k8s.io/v1beta2"
kind: SparkApplication
metadata:
  name: streamprocessor
  namespace: ${var.namespace}
spec:
  type: Scala
  mode: cluster
  image: docker.io/library/finnhub-streaming-data-pipeline-spark-k8s:latest
  imagePullPolicy: Never
  mainClass: StreamProcessor
  mainApplicationFile: "local:///opt/spark/jars/streamprocessor-assembly-1.0.jar"
  sparkVersion: "3.0.0"
  restartPolicy:
    type: OnFailure
    onFailureRetries: 3
    onFailureRetryInterval: 10
    onSubmissionFailureRetries: 3
    onSubmissionFailureRetryInterval: 10
  driver:
    cores: 1
    memory: "512m"
    serviceAccount: spark
    javaOptions: "-Dconfig.resource=deployment.conf"
    envFrom:
    - configMapRef:
        name: pipeline-config
    - secretRef:
        name: pipeline-secrets
  executor:
    cores: 1
    instances: 1
    memory: "2g"
    javaOptions: "-Dconfig.resource=deployment.conf"
    envFrom:
    - configMapRef:
        name: pipeline-config
    - secretRef:
        name: pipeline-secrets
YAML
}