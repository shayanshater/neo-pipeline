import os
import logging
import awswrangler as wr
import psycopg2

logger = logging.getLogger()
logger.setLevel(logging.INFO)

DB_HOST     = os.environ["DB_HOST"]
DB_PORT     = os.environ["DB_PORT"]
DB_NAME     = os.environ["DB_NAME"]
DB_USER     = os.environ["DB_USER"]
DB_PASSWORD = os.environ["DB_PASSWORD"]


def get_connection():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )

def load_to_postgres(df):
    conn = get_connection()
    cursor = conn.cursor()

    # for _, row in df.iterrows():
    #     cursor.execute("""
    #         INSERT INTO asteroids (
    #             asteroid_id,
    #             name,
    #             close_approach_date,
    #             is_hazardous,
    #             diameter_min_km,
    #             diameter_max_km,
    #             diameter_avg_km,
    #             velocity_kmh,
    #             miss_distance_km,
    #             miss_distance_lunar,
    #             ingested_at
    #         ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    #         ON CONFLICT (asteroid_id, close_approach_date) DO NOTHING
    #     """, (
    #         row["asteroid_id"],
    #         row["name"],
    #         row["close_approach_date"],
    #         row["is_hazardous"],
    #         row["diameter_min_km"],
    #         row["diameter_max_km"],
    #         row["diameter_avg_km"],
    #         row["velocity_kmh"],
    #         row["miss_distance_km"],
    #         row["miss_distance_lunar"],
    #         row["ingested_at"]
    #     ))

    conn.commit()
    cursor.close()
    conn.close()


def lambda_handler(event, context):
    # Get the file that triggered this Lambda
    bucket = event["Records"][0]["s3"]["bucket"]["name"]
    key    = event["Records"][0]["s3"]["object"]["key"]
    logger.info(f"Loading: s3://{bucket}/{key}")

    # Read parquet from S3
    df = wr.s3.read_parquet(path=f"s3://{bucket}/{key}")
    logger.info(f"Read {len(df)} rows from parquet")

    # Load into PostgreSQL
    load_to_postgres(df)
    logger.info(f"Successfully loaded {len(df)} rows into asteroids table")

    return {"status": "loaded", "rows": len(df), "source": key}