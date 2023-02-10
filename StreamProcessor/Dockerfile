FROM gcr.io/spark-operator/spark:v3.0.0

WORKDIR /opt/spark/jars

COPY target/dependency/ .

COPY target/scala-2.12/streamprocessor-assembly-1.0.jar .

USER root

