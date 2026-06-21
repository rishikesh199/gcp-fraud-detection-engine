# 🎼 Airflow DAGs — Cloud Composer Orchestration

This directory contains **Apache Airflow DAGs** that run on **Cloud Composer 2** for orchestrating the batch fraud detection pipeline.

## What's Inside
- `fraud_batch_pipeline_dag.py` — Main batch pipeline DAG
- `data_quality_dag.py` — Data quality check DAG
- `cleanup_dag.py` — Resource cleanup DAG (cost optimization)

## Main DAG Flow (fraud_batch_pipeline_dag)
1. **check_source_data** — Verify raw data exists in GCS
2. **create_dataproc_cluster** — Spin up ephemeral Dataproc cluster
3. **submit_pyspark_etl** — Run PySpark ETL job
4. **delete_dataproc_cluster** — Delete cluster (cost savings!)
5. **trigger_dbt_run** — Trigger dbt Cloud job via API
6. **validate_bigquery_data** — Check data loaded correctly
7. **send_notification** — Email/Slack success notification

## Deployment
DAGs are synced to Cloud Composer's GCS bucket automatically.

## Schedule
- **Batch pipeline**: Daily at 2:00 AM IST
- **Data quality**: Daily at 4:00 AM IST (after batch completes)
