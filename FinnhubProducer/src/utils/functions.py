import json
import finnhub
import io
import avro.schema
import avro.io
from kafka import KafkaProducer

#setting up Finnhub client connection to test if tickers specified in config exist
def load_client(token):
    return finnhub.Client(api_key=token)

#look up ticker in Finnhub
def lookup_ticker(finnhub_client,ticker):
    return finnhub_client.symbol_lookup(ticker)

#validate if ticker exists
def ticker_validator(finnhub_client,ticker):
    for stock in lookup_ticker(finnhub_client,ticker)['result']:
        if stock['symbol']==ticker:
            return True
    return False

#setting up a Kafka connection
def load_producer(kafka_server):
    return KafkaProducer(bootstrap_servers=kafka_server)

#parse Avro schema
def load_avro_schema(schema_path):
    return avro.schema.parse(open(schema_path).read())
    
#encode message into avro format
def avro_encode(data, schema):
    writer = avro.io.DatumWriter(schema)
    bytes_writer = io.BytesIO()
    encoder = avro.io.BinaryEncoder(bytes_writer)
    writer.write(data, encoder)
    return bytes_writer.getvalue()