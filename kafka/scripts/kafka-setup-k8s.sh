# blocks until kafka is reachable
kafka-topics --bootstrap-server localhost:29092 --list
echo -e 'Creating kafka topics'
kafka-topics --bootstrap-server localhost:29092 --create --if-not-exists --topic market --replication-factor 1 --partitions 1
echo -e 'Successfully created the following topics:'
kafka-topics --bootstrap-server localhost:29092 --list