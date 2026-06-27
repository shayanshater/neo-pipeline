import requests
import json
import boto3
import logging
from datetime import date
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)
NASA_API_KEY = os.environ["NASA_API_KEY"]
S3_BUCKET_NAME = os.environ["S3_BUCKET_NAME"]

def lambda_handler(event, context):
    today = date.today().isoformat()
    logger.info(f"Starting extraction for {today}")

    # 1. Call the API
    response = requests.get(
        "https://api.nasa.gov/neo/rest/v1/feed",
        params={
            "start_date": today,
            "end_date": today,
            "api_key": NASA_API_KEY  # store in AWS Secrets Manager
        }
    )
    response.raise_for_status()
    logger.info("successful NASA API request")
    data = response.json()

    

    # 2. Store raw JSON to S3
    logger.info("beginning to send data to s3")
    s3 = boto3.client("s3")
    s3.put_object(
        Bucket=S3_BUCKET_NAME,
        Key=f"raw/{today}.json",
        Body=json.dumps(data)
    )
    logger.info("data successfully landed in s3, ready for next phase")
    
    return {"status": "ingested", "date": today}


