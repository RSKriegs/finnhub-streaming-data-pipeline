#This is an utility script to look up for stock tickers locally before running the pipeline.
#Requires finnhub package - run pip install finnhub-python before running, or run requirements.txt file

import argparse
import os
from src.utils.functions import load_client, lookup_ticker

if __name__ == '__main__':
    #finnhub_client = load_client('') #uncomment this, insert token and comment following line to run locally
    finnhub_client = load_client(os.environ['FINNHUB_API_TOKEN'])

    parser = argparse.ArgumentParser(description="Get list of tickers based on Finnhub search",
                                     prog="ticker_search.py",
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--ticker', type=str,
                        help="Enter the phrase to look up for a ticker")

    args = parser.parse_args()
    params = vars(args)

    try:
        print(lookup_ticker(finnhub_client,params['ticker']))
    except Exception as e:
        print(str(e))
