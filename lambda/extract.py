import requests
import json
import boto3
from datetime import date
import os

def lambda_handler():
        # event, context):
    today = date.today().isoformat()

    NASA_API_KEY = os.getenv("NASA_API_KEY")
    # 1. Call the API
    response = requests.get(
        "https://api.nasa.gov/neo/rest/v1/feed",
        params={
            "start_date": today,
            "end_date": today,
            "api_key": NASA_API_KEY  # store in AWS Secrets Manager
        }
    )
    data = response.json()

    

    # 2. Store raw JSON to S3
    s3 = boto3.client("s3")
    buckets = s3.list_buckets(
        Prefix = "neo-data-lake-"
    )
    neo_bucket_name = buckets['Buckets'][0]['Name']
    s3.put_object(
        Bucket=neo_bucket_name,
        Key=f"raw/{today}.json",
        Body=json.dumps(data)
    )
    
    return {"status": "ingested", "date": today}


