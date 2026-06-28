import os
import json
import logging
import boto3
import pandas as pd
import awswrangler as wr
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

S3_TRANSFORM_BUCKET_NAME = os.environ["S3_TRANSFORM_BUCKET_NAME"]

def flatten_neo_data(data: dict) -> pd.DataFrame:
    rows = []
    for date_str, asteroids in data["near_earth_objects"].items():
        for neo in asteroids:
            approach = neo["close_approach_data"][0]
            rows.append({
                "asteroid_id":        neo["id"],
                "name":               neo["name"],
                "close_approach_date": date_str,
                "is_hazardous":       neo["is_potentially_hazardous_asteroid"],
                "diameter_min_km":    float(neo["estimated_diameter"]["kilometers"]["estimated_diameter_min"]),
                "diameter_max_km":    float(neo["estimated_diameter"]["kilometers"]["estimated_diameter_max"]),
                "velocity_kmh":       float(approach["relative_velocity"]["kilometers_per_hour"]),
                "miss_distance_km":   float(approach["miss_distance"]["kilometers"]),
                "miss_distance_lunar": float(approach["miss_distance"]["lunar"]),
                "ingested_at":        datetime.utcnow().isoformat()
            })
    return pd.DataFrame(rows)

def lambda_handler(event, context):
    # Get the file that triggered this Lambda from the event
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key = event["Records"][0]["s3"]["object"]["key"]
    logger.info(f"Processing: s3://{bucket}/{key}")

    # Read raw JSON from S3
    s3 = boto3.client("s3")
    response = s3.get_object(Bucket=bucket, Key=key)
    data = json.loads(response["Body"].read())

    # Transform
    df = flatten_neo_data(data)
    logger.info(f"Flattened {len(df)} asteroid rows")

    # Write parquet to processed bucket
    date_str = key.split("/")[-1].replace(".json", "")
    output_path = f"s3://{S3_TRANSFORM_BUCKET_NAME}/processed/{date_str}.parquet"
    wr.s3.to_parquet(df=df, path=output_path)
    logger.info(f"Written to {output_path}")

    return {"status": "transformed", "rows": len(df), "output": output_path}