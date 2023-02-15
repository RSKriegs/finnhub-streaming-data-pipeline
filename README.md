# Finnhub Streaming Data Pipeline

The project is a streaming data pipeline based on Finnhub.io API/websocket real-time trading data created for a sake of my master's thesis related to stream processing.
It is designed with a purpose to showcase key aspects of streaming pipeline development & architecture, providing low latency, scalability & availability.

## Architecture

![finnhub_streaming_data_pipeline_diagram drawio (4)](https://user-images.githubusercontent.com/75480707/218998119-12d514ef-8e10-40e7-a638-afaa728e6b4f.png)

The diagram below provides a detailed insight into pipeline's architecture. 
All applications are containerized into **Docker** containers, which are orchestrated by **Kubernetes** - and its infrastructure is managed by **Terraform**.
**Data ingestion layer** - a containerized **Python** application called **FinnhubProducer** connects to Finnhub.io websocket. It encodes retrieved messages into Avro format as specified in schemas/trades.avsc file and ingests messages into Kafka broker.
**Message broker layer** - messages from FinnhubProducer are consumed by **Kafka** broker, which is located in kafka-service pod and has *Kafdrop* service as a sidecar ambassador container for Kafka. On a container startup, **kafka-setup-k8s.sh** script runs to create topics. The **Zookeeper** pod is launched before Kafka as it is required for its metadata management.
**Stream processing layer** - a **Spark** Kubernetes cluster based on spark-k8s-operator is deployed using Helm. A **Scala** application called **StreamProcessor** is submitted into Spark cluster manager, that delegates a worker for it. This application connects to Kafka broker to retrieve messages, transform them using Spark Structured Streaming, and loads into Cassandra tables. The first query - that transforms trades into feasible format - runs continuously, whereas the second - with aggregations - has a 5 seconds trigger.
**Serving database layer** - a **Cassandra** database stores & persists data from Spark jobs. Upon launching, the cassandra-setup.cql script runs to create keyspace & tables.
**Visualization layer** - **Grafana** connects to Cassandra database using HadesArchitect-Cassandra-Plugin and serves visualized data to users as in example of Finnhub Sample BTC Dashboard. The dashboard is refreshed each 500ms.

## Dashboard

TODO

## Setup & deployment

TODO

## Room for improvements

TODO
