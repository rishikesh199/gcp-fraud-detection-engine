# 🌊 Streaming Pipeline — Dataflow / Apache Beam

This directory contains the **Apache Beam** pipeline code that runs on **Cloud Dataflow** for real-time fraud transaction processing.

## What's Inside
- `pipeline.py` — Main Beam pipeline (Pub/Sub → Transform → BigQuery)
- `transforms/` — Custom PTransform classes
- `schemas/` — BigQuery table schemas
- `utils/pii_masking.py` — PII masking utilities (DLP + SHA-256)
- `requirements.txt` — Python dependencies

## Pipeline Flow
1. Read from Pub/Sub topic
2. Parse JSON transaction
3. Apply fraud scoring rules
4. Mask PII (Cloud DLP sampling + SHA-256 hashing)
5. Write to BigQuery streaming table
6. Side output: High-value fraud alerts

## Deployment (from Cloud Shell)
```bash
python streaming_pipeline/pipeline.py \
  --runner DataflowRunner \
  --project fraud-detection-de-project-2026 \
  --region asia-south1 \
  --temp_location gs://fraud-dev-temp/dataflow/ \
  --service_account_email sa-dataflow-fraud-dev@fraud-detection-de-project-2026.iam.gserviceaccount.com
```
