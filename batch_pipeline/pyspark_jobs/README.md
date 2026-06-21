# ⚡ Batch Pipeline — PySpark Jobs on Dataproc

This directory contains **PySpark** jobs that run on **Cloud Dataproc** for batch processing of historical fraud data.

## What's Inside
- `etl_raw_to_processed.py` — Main ETL job (CSV → cleaned Parquet)
- `write_to_iceberg.py` — Write processed data to Apache Iceberg tables
- `data_quality_checks.py` — Data validation and quality checks
- `feature_engineering.py` — Feature creation for fraud analysis

## Pipeline Flow
1. Read raw CSV from GCS (gs://fraud-dev-raw-data/)
2. Clean & validate data (nulls, types, ranges)
3. Feature engineering (hour extraction, amount bins, velocity)
4. Write as Parquet to GCS processed zone
5. Create/update Apache Iceberg tables
6. Load to BigQuery external tables

## Execution (via Cloud Composer or manually)
```bash
gcloud dataproc jobs submit pyspark \
  batch_pipeline/pyspark_jobs/etl_raw_to_processed.py \
  --cluster=fraud-dev-dataproc-cluster \
  --region=asia-south1 \
  --properties=spark.jars.packages=org.apache.iceberg:iceberg-spark-runtime-3.3_2.12:1.4.2
```
