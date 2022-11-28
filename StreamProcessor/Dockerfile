FROM bde2020/spark-sbt-template:3.2.1-hadoop3.2

COPY ./spark/target/dependency /spark/jars

ENV SPARK_APPLICATION_MAIN_CLASS StreamProcessor
ENV SPARK_APPLICATION_ARGS "--packages org.apache.spark:spark-sql-kafka-0-10_2.12-3.2.1,org.apache.spark:spark-avro_2.12:3.2.1, \
                            spark-cassandra-connector_2.12-3.2.0,cassandra-driver-core-3.11.13"
