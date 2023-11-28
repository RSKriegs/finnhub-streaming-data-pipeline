The related master's thesis is shared on Google Drive here:  https://drive.google.com/file/d/17BBSlaHi5MKmo0qygaceogeOweqCWx9n/view?usp=drivesdk
---
# Finnhub Streaming Data Pipeline

The project is a streaming data pipeline based on Finnhub.io API/websocket real-time trading data created for a sake of my master's thesis related to stream processing.
It is designed with a purpose to showcase key aspects of streaming pipeline development & architecture, providing low latency, scalability & availability.

## Architecture

![finnhub_streaming_data_pipeline_diagram drawio (4)](https://user-images.githubusercontent.com/75480707/218998119-12d514ef-8e10-40e7-a638-afaa728e6b4f.png)

The diagram above provides a detailed insight into pipeline's architecture. 

All applications are containerized into **Docker** containers, which are orchestrated by **Kubernetes** - and its infrastructure is managed by **Terraform**.

**Data ingestion layer** - a containerized **Python** application called **FinnhubProducer** connects to Finnhub.io websocket. It encodes retrieved messages into Avro format as specified in schemas/trades.avsc file and ingests messages into Kafka broker.

**Message broker layer** - messages from FinnhubProducer are consumed by **Kafka** broker, which is located in kafka-service pod and has **Kafdrop** service as a sidecar ambassador container for Kafka. On a container startup, **kafka-setup-k8s.sh** script runs to create topics. The **Zookeeper** pod is launched before Kafka as it is required for its metadata management.

**Stream processing layer** - a **Spark** Kubernetes cluster based on spark-k8s-operator is deployed using Helm. A **Scala** application called **StreamProcessor** is submitted into Spark cluster manager, that delegates a worker for it. This application connects to Kafka broker to retrieve messages, transform them using Spark Structured Streaming, and loads into Cassandra tables. The first query - that transforms trades into feasible format - runs continuously, whereas the second - with aggregations - has a 5 seconds trigger.

**Serving database layer** - a **Cassandra** database stores & persists data from Spark jobs. Upon launching, the **cassandra-setup.cql** script runs to create keyspace & tables.

**Visualization layer** - **Grafana** connects to Cassandra database using HadesArchitect-Cassandra-Plugin and serves visualized data to users as in example of Finnhub Sample BTC Dashboard. The dashboard is refreshed each 500ms.

## Dashboard

![ezgif com-crop](https://user-images.githubusercontent.com/75480707/219054392-5cc6a3e6-b034-4e75-8cb5-3baafe001149.gif)

You can access Grafana with a dashboard on localhost:3000 by running following command:
```
kubectl port-forward -n pipeline service/grafana 3000:3000
```
You can also modify it for your liking from UI - but if you want to save anything, you will need to export json and load it into Docker image.
Remember that if you change namespace name in Terraform variables you need to apply it into that command as well.

## Setup & deployment

The application is designed to be deployed on a local Minikube cluster. However, the deployment into EKS/GKE/AKS should be quite straight-forward, with tweaking deployment settings for providers, volumes etc.

Running the application requires you to have a Finnhub API token. You can retrieve it once you have created a Finnhub account. To include it in final deployment, insert it into proper fields in terraform-k8s/config.tf, along with Cassandra database username & password of choice. While setting Cassandra credentials remember to verify them with Grafana dashboard settings (the issue is referenced in config.tf file).

There is also an old setup that relies solely on docker-compose. To reach that, navigate to the docker-compose-old branch.

I was running this cluster on Windows with Minikube, Helm, Docker Desktop and Terraform pre-installed. I have utilized local Docker registry to apply custom images into deployment. I was launching it with no vtx enabled, using VirtualBox as VM engine. Below attached are scripts that I was running in Powershell in order to run the cluster as intended:

```
set HTTP_PROXY=http://<proxy hostname:port>
set HTTPS_PROXY=https://<proxy hostname:port>
set NO_PROXY=localhost,127.0.0.1,10.96.0.0/12,192.168.59.0/24,192.168.49.0/24,192.168.39.0/24

minikube start --no-vtx-check --memory 10240 --cpus 6

minikube docker-env
set DOCKER_TLS_VERIFY=”1"
set DOCKER_HOST=”tcp://172.17.0.2:2376"
set DOCKER_CERT_PATH=”/home/user/.minikube/certs”
set MINIKUBE_ACTIVE_DOCKERD=”minikube”

minikube docker-env | Invoke-Expression

docker-compose -f docker-compose-ci.yaml build --no-cache

cd terraform-k8s
terraform apply
```

## Potential improvements

There is definitely some room for improvement for the pipeline. The solution itself has some issues at the moment and there are some ideas that would enable its full potential in production:

- November 2023 update: deleted SparkOperator image

It seems that the SparkOperator image from Google Container Registry is deleted, therefore the pipeline will fail to build. If you would like to run the pipeline on your own, you will need to replace the Spark image first and possibly alter some configuration settings.

- Cloud deployment

The pipeline was developed locally on Minikube, but deploying it into one of Kubernetes services of major cloud vendors would massively improve its scalability & reliability. This would be a must-have in real-life commercialized deployment.

- Developing CI/CD pipeline

The current CI_build.yml file for Github Actions is a remnant of old docker-compose version and setting up CI for Kubernetes & Terraform, along with pipeline testing, would require much more work, which was not necessary for me as I was developing & testing everything locally. However, it would be essential to implement that on a larger scale deployment, along with adding CD for cloud deployment.

- Visualization tool

Although I have used Grafana for final visualization layer, I would look forward to spend more time implementing other solution as Grafana, especially while using external plugin, has limited capabilities for data analytics. Personally I would recommend to go with open-source BI solution, such as Apache Superset, and spin Cassandra into Presto engine, or develop custom Streamlit app.

- Cassandra initial startup fix

At initial Kubernetes deployment, Cassandra deployment might fail once or twice with PostHookStartErrors. It is most likely related to its gossiping protocol at the startup, and lifecycle->postStart command runs too early. Extending sleep time in postStart command would help to address that, but it would extend startup times later on. Implementing readiness/liveness probe might be helpful for that.

- Deploying Cassandra & Kafka as StatefulSets

Right now, Cassandra & Kafka are configured to be standard deployments. However, implementing them as StatefulSets would be desired in order to improve their scalability and reliability at scale.

- adding Cassandra Web UI as ambassador

Adding some sort of Cassandra Web UI as a sidebar ambassador container to Cassandra deployment would be helpful for operations & log analytics.

- volumeMounts instead of Dockerfiles

For some features, for example Grafana dashboards or Kafka setup script, volumeMounts would be more convenient rather than copying content into Docker image, as it wouldn't enforce rebuilding it.

- code cleanup & further development

There is room to develop more advanced codebase into a project, for example to implement Lambda architecture & batch processing for some use cases, or improve Kubernetes deployment configuration. Some code for applications might also be cleaned up and/or optimized (for example for build.sbt).
