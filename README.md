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

TODO
- insert gif with dashboard

## Setup & deployment

TODO
Minikube, Docker Desktop & Terraform.
- describe what to do
- include Powershell commands
- mention docker-compose-old branch

## Potential improvements

There is definitely some room for improvement for the pipeline. The solution itself has some issues at the moment and there are some ideas that would enable its full potential in production:

- Cloud deployment

The pipeline was developed locally on Minikube, but deploying it into one of Kubernetes services of major cloud vendors would massively improve its scalability & reliability. This would be a must-have in real-life commercialized deployment.

- Developing CI/CD pipeline

The current CI_build.yml file is a remnant of old docker-compose version and setting up CI for Kubernetes & Terraform, along with pipeline testing, would require much more work, which was not necessary for me as I was developing everything locally. However, it would be essential to implement that on a larger scale deployment, along with adding CD for cloud deployment.

- Visualization tool

Although I have used Grafana for final visualization layer, I would look forward to spend more time implementing other solution as Grafana, especially while using external plugin, has limited capabilities for data analytics. Personally I would recommend to go with open-source BI solution, such as Apache Superset, and spin Cassandra into Presto engine, or develop custom Streamlit app.

- Kafdrop fix

Despite being included in final deployment, I have run into issues with exposing Kafdrop. It simply began to not work at some point of development stage of Kubernetes deployment. A deep dive into that issue is required.

- Cassandra initial startup fix

At initial Kubernetes deployment, Cassandra deployment might fail once or twice with PostHookStartErrors. It is most likely related to its gossiping protocol at the startup, and lifecycle->postStart command runs too early. Extending sleep time in postStart command would help to address that, but it would extend startup times later on. Implementing readiness/liveness probe might be helpful for that.

- Deploying Cassandra & Kafka as StatefulSets

Right now, Cassandra & Kafka are configured to be standard deployments. However, implementing them as StatefulSets would be desired in order to improve their scalability and reliability at scale.

- adding Cassandra Web UI as ambassador

Adding some sort of Cassandra Web UI as a sidebar ambassador container to Cassandra deployment would be helpful for operations & log analytics.

- add persistent volume for Kafka

Adding persistent volumes at message broker stage would add some fail-safe storage and relability to the system. In case of system failure, the raw data could be retrieved later for transformation.

- verifying environment parametrization & Kubernetes configuration
Some Kafka/Spark/Cassandra parameters might be unnecessary or even suboptimal pipeline, but also some other parameters might be added in order to improve performance & reliability. Adding more environment variables into configMap, or Terraform variables might also improve code readability. There are also some more existing & potential features to Kubernetes deployments to be analyzed.

- code cleanup & further development
There is room to develop more advanced codebase into a project, for example to implement Lambda architecture & batch processing for some use cases. Some code for applications might also be cleaned up and/or optimized (for example for build.sbt).
