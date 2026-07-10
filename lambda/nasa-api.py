import requests
import json
from datetime import date
import os
from dotenv import load_dotenv
from transform import flatten_neo_data
from pprint import pprint
load_dotenv()

today = date.today().isoformat()
NASA_API_KEY = os.environ["NASA_API_KEY"]
response = requests.get(
        "https://api.nasa.gov/neo/rest/v1/feed",
        params={
            "start_date": today,
            "end_date": today,
            "api_key": NASA_API_KEY  # store in AWS Secrets Manager
        }
    )
response.raise_for_status()
data = response.json()

pprint(data)