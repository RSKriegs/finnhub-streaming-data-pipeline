FROM grafana/grafana-oss:9.2.6

COPY ./provisioning /etc/grafana/provisioning
COPY ./dashboards /var/lib/grafana/dashboards
COPY ./grafana.ini /etc/grafana/grafana.ini

RUN /bin/bash -c 'grafana-cli plugins install hadesarchitect-cassandra-datasource'