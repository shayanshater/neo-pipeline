# 🚀 NASA Near-Earth Object (NEO) Pipeline

> An automated, serverless data pipeline that ingests, transforms, and stores daily asteroid close-approach data from NASA's NeoWs API — built by a physics graduate who wanted to do something useful with orbital mechanics.

---

## Overview

Near-Earth Objects (NEOs) are asteroids and comets whose orbits bring them close to Earth. NASA tracks thousands of them daily. This project builds a fully automated cloud pipeline to capture that data, transform it into a clean analytical format, and store it for querying and visualisation.

**Why this project?** I studied physics at King's College London and wanted to combine my understanding of orbital dynamics with production-grade data engineering tooling. This pipeline runs daily without any manual intervention.

---

## Architecture

```
NASA NeoWs API
      │
      ▼
AWS Lambda (Ingestion)
      │  Triggered daily by EventBridge
      ▼
Amazon S3 (Raw Layer)
      │  raw/YYYY-MM-DD.json
      ▼
AWS Lambda (Transformation)
      │  Flattens JSON → tabular rows
      ▼
Amazon S3 (Processed Layer)
      │  processed/YYYY-MM-DD.parquet
      ▼
Amazon RDS PostgreSQL
      │
      ▼
Dashboard (Plotly / Streamlit)
```

All infrastructure is defined and deployed with **Terraform**. The Lambda functions are containerised with **Docker**.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Ingestion | Python, AWS Lambda |
| Storage | Amazon S3 (raw + processed) |
| Transformation | Python, pandas |
| Database | Amazon RDS PostgreSQL |
| Infrastructure | Terraform |
| Scheduling | Amazon EventBridge |
| Monitoring | Amazon CloudWatch |
| Containerisation | Docker |
| CI/CD | GitHub Actions |
| Package management | uv |

---

## Data

The pipeline pulls from NASA's free [NeoWs API](https://api.nasa.gov). Each daily run captures:

| Field | Description |
|---|---|
| `name` | Asteroid designation |
| `close_approach_date` | Date of closest pass |
| `miss_distance_km` | Distance from Earth at closest approach |
| `miss_distance_lunar` | Miss distance in lunar distances (1 = Moon's orbit) |
| `velocity_km_per_hour` | Relative velocity to Earth |
| `diameter_min_km` | Minimum estimated diameter |
| `diameter_max_km` | Maximum estimated diameter |
| `is_potentially_hazardous` | NASA hazard classification (boolean) |

---

## Project Structure

```
neo-pipeline/
├── terraform/               # All infrastructure as code
│   ├── init.tf
│   ├── s3.tf
│   ├── iam.tf
│   ├── lambda-function.tf
│   └── variables.tf
├── lambda/                  # Lambda function source code
│   ├── ingestion/
│   │   └── main.py          # Calls NASA API → writes raw JSON to S3
│   └── transformation/
│       └── main.py          # Flattens JSON → loads to PostgreSQL
├── tests/                   # Unit tests
├── .github/workflows/       # CI/CD pipeline
├── pyproject.toml           # Python deps managed with uv
├── .gitignore
└── README.md
```

---

## Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6
- [uv](https://docs.astral.sh/uv/) for Python dependency management
- [AWS CLI](https://aws.amazon.com/cli/) configured with your credentials
- A free [NASA API key](https://api.nasa.gov)

### 1. Clone the repo

```bash
git clone https://github.com/shayanshater/neo-pipeline.git
cd neo-pipeline
```

### 2. Install Python dependencies

```bash
uv sync
```

### 3. Configure environment variables

```bash
cp .env.example .env
# Add your NASA_API_KEY and AWS credentials
```

### 4. Deploy infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 5. Trigger the pipeline manually

```bash
aws lambda invoke \
  --function-name neo-ingestion \
  --payload '{}' \
  response.json
```

The pipeline will then run automatically every day via EventBridge.

---

## Key Design Decisions

**Why Lambda over a long-running service?** The pipeline only needs to run once per day and processes a small payload (~50 asteroids). Lambda is cheaper, simpler, and more appropriate than EC2 or ECS for this workload.

**Why store raw JSON in S3 before transforming?** This preserves the source data exactly as NASA returned it. If the transformation logic changes, the raw layer can be reprocessed without re-calling the API. This is the medallion architecture pattern used in production data lakes.

**Why PostgreSQL over a data warehouse?** The dataset is small enough that a relational database is the right fit. A full data warehouse (Redshift, BigQuery) would be over-engineered for this scale.

---

## What I Learned

- Deploying serverless infrastructure with Terraform end-to-end
- Structuring a data lake with separate raw and processed layers
- Managing Python packaging for Lambda deployment using `uv`
- Working with a real REST API and handling nested JSON at scale
- IAM least-privilege patterns for Lambda ↔ S3 ↔ RDS access

---

## Roadmap

- [ ] Add dbt for SQL-based transformation layer
- [ ] Streamlit dashboard showing hazardous asteroid trends over time
- [ ] SNS alert when a potentially hazardous asteroid passes within 5 lunar distances
- [ ] Backfill historical data from 2020 onwards

---

## Author

**Shayan** — MSci Physics, King's College London  
[GitHub](https://github.com/shayanshater) · [LinkedIn](#)

---

## Licence

MIT