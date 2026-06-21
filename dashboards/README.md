# 📊 Dashboards — Looker Studio Configurations

This directory contains documentation and configurations for **Looker Studio** dashboards.

## What's Inside
- `dashboard_design.md` — Dashboard layout and design specifications
- `screenshots/` — Dashboard screenshots for documentation
- `queries/` — BigQuery SQL queries used by dashboard widgets

## Dashboards
1. **Fraud Detection Overview** — Real-time fraud metrics, KPIs
2. **Transaction Analysis** — Volume trends, amount distributions
3. **Merchant Risk Score** — Risk scoring by merchant category
4. **Geographic Analysis** — Fraud by location/region

## Data Sources
- BigQuery dataset: `fraud_analytics_dev`
- Tables: dbt mart models (`mart_fraud_summary`, `mart_daily_metrics`)

## Access
Looker Studio dashboards are accessed via browser at lookerstudio.google.com
