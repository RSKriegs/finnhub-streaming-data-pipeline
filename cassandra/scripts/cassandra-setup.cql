DROP KEYSPACE IF EXISTS market;

CREATE KEYSPACE market WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

USE market;

CREATE TABLE trades(
    uuid uuid,
    trade_conditions text,
    price double,
    symbol text,
    trade_timestamp timestamp,
    ingest_timestamp timestamp,
    volume double,
    type text,
    PRIMARY KEY((symbol),trade_timestamp)
);

CREATE INDEX IF NOT EXISTS ON trades (uuid);

CREATE TABLE running_averages_15_sec(
    uuid uuid,
    symbol text,
    price_volume_multiply double,
    ingest_timestamp timestamp,
    PRIMARY KEY((uuid),ingest_timestamp)
);

CREATE INDEX IF NOT EXISTS ON running_averages_15_sec (symbol);