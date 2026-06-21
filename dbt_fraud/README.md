# 🔄 dbt Fraud — Data Transformation with dbt Cloud

This directory contains the **dbt** project for transforming raw fraud data into analytics-ready models in **BigQuery**.

## What's Inside
- `models/staging/` — Source data cleaning and standardization
- `models/intermediate/` — Business logic transformations
- `models/marts/` — Final analytics tables for dashboards
- `tests/` — Data quality tests (uniqueness, not null, accepted values)
- `macros/` — Reusable SQL macros
- `dbt_project.yml` — dbt project configuration
- `profiles.yml` — Connection configuration (managed by dbt Cloud)

## Model Layers
1. **Staging**: `stg_transactions`, `stg_fraud_labels`
2. **Intermediate**: `int_transactions_enriched`, `int_fraud_features`
3. **Marts**: `mart_fraud_summary`, `mart_daily_metrics`, `mart_merchant_risk`

## Execution
Managed by **dbt Cloud** — runs are triggered via dbt Cloud UI or Cloud Composer DAG.

## Connection
- **Warehouse**: BigQuery
- **Dataset**: fraud_analytics_dev
- **Service Account**: sa-dbt-fraud-dev
