import requests
import json
import boto3
from datetime import date
from dotenv import load_dotenv
load_dotenv()

def lambda_handler():
        # event, context):
    today = date.today().isoformat()
    
    # 1. Call the API
    response = requests.get(
        "https://api.nasa.gov/neo/rest/v1/feed",
        params={
            "start_date": today,
            "end_date": today,
            "api_key": "YOUR_KEY"  # store in AWS Secrets Manager
        }
    )
    data = response.json()
    
    # 2. Store raw JSON to S3
    s3 = boto3.client("s3")
    s3.put_object(
        Bucket="your-neo-raw-bucket",
        Key=f"raw/{today}.json",
        Body=json.dumps(data)
    )
    
    return {"status": "ingested", "date": today}


lambda_handler()
