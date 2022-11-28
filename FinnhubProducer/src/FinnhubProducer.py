#Main file for Finnhub API & Kafka integration
import websocket
import json
from utils.functions import *

#proper class that ingests upcoming messages from Finnhub websocket into Kafka
class FinnhubProducer:
    
    def __init__(self):
        
        self.config = load_config('config.json')
        self.finnhub_client = load_client(self.config['FINNHUB_API_TOKEN'])
        self.producer = load_producer(self.config['KAFKA_SERVER'])
        self.avro_schema = load_avro_schema('schemas/trades.avsc')
        self.validate = self.config['FINNHUB_VALIDATE_TICKERS']

        websocket.enableTrace(True)
        self.ws = websocket.WebSocketApp(f"wss://ws.finnhub.io?token={self.config['FINNHUB_API_TOKEN']}",
                              on_message = self.on_message,
                              on_error = self.on_error,
                              on_close = self.on_close)
        self.ws.on_open = self.on_open
        self.ws.run_forever()

    def on_message(self, ws, message):
        message = json.loads(message)
        avro_message = avro_encode(
            {
                'data': message['data'],
                'type': message['type']
            }, 
            self.avro_schema
        )
        self.producer.send(self.config['KAFKA_TOPIC'], avro_message)

    def on_error(self, ws, error):
        print(error)

    def on_close(self, ws):
        print("### closed ###")

    def on_open(self, ws):
        for ticker in self.config['FINNHUB_STOCKS_TICKERS']:
            if self.validate==1:
                if(ticker_validator(self.finnhub_client,ticker)==True):
                    self.ws.send('{"type":"subscribe","symbol":"'+ticker+'"}')
                    print(f'Subscription for {ticker} succeeded')
                else:
                    print(f'Subscription for {ticker} failed - ticker not found')
            else:
                self.ws.send('{"type":"subscribe","symbol":"'+ticker+'"}')

if __name__ == "__main__":
    FinnhubProducer()