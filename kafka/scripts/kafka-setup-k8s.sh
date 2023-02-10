# for some reason this script stopped working in a meantime while deployed to Kafka pod that's why it's not used in a final deployment.
# TODO: fix the issue above

kafka-topics --bootstrap-server localhost:29092 --list

echo -e 'Creating kafka topics'
kafka-topics --bootstrap-server localhost:29092 --create --if-not-exists --topic market --replication-factor 1 --partitions 1

echo -e 'Successfully created the following topics:'
kafka-topics --bootstrap-server localhost:29092 --list
