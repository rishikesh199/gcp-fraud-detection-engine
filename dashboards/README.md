# Business Intelligence & Dashboards

## 📌 Enterprise Purpose
Data Engineering pipelines are useless without actionable business insights. This module contains the frontend visualization assets (Power BI) that connect directly to the BigQuery Data Warehouse (`fraud_marts_dev`). It empowers the Fraud Operations team to monitor real-time threat landscapes, track blocked transactions, and analyze historical fraud trends across geographical and merchant dimensions.

## 📊 Connected Data Models (Star Schema)
The dashboards connect to the following dbt-materialized tables via **DirectQuery** or **Import Mode**:
- `fct_fraud_transactions`
- `fct_fraud_kpis`
- `dim_geography`
- `dim_merchant_category`

## 📈 Key Metrics Visualized
1. **Real-time Fraud Rate (%):** Monitoring spikes in fraudulent activity over the last 1-hour rolling window.
2. **Top High-Risk Merchants:** Identifying merchant categories most susceptible to spoofing.
3. **Geographical Heatmaps:** Mapping the origin of anomalous transactions (e.g., cross-border Card-Not-Present fraud).
4. **Volume vs. Block Rate:** Tracking the efficiency of the streaming pipeline's filtering rules.

## 🚀 Usage Instructions
1. Open the `.pbix` (Power BI) file.
2. In Power Query, update the BigQuery connection string to point to your specific GCP Project ID.
3. Authenticate using your Google Cloud organizational account.
